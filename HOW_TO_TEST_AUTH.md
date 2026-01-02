# How to Test Authentication

This guide will help you test the authentication flow that was implemented in Phase 2.

## Prerequisites

Make sure both backend and frontend servers are running:

```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Frontend
cd frontend
npm run dev
```

## Test Scenarios

### 1. Login with Valid Credentials ✅

**Steps**:
1. Open browser to `http://localhost:5173`
2. You should see the login page with:
   - McDonald's branding
   - Environment indicator (TEST ENVIRONMENT in red)
   - Username and password fields
   - Remember me checkbox
   - Login button
3. Enter valid credentials for a McDonald's user in the test environment
4. Click "Login"

**Expected Result**:
- Loading spinner appears on button
- Success toast notification appears (green, top-right)
- Redirects to `/home/dashboard`
- Token stored in localStorage
- User data stored in localStorage

**Check**:
```javascript
// Open browser console
localStorage.getItem('auth_token')  // Should return token
localStorage.getItem('auth_user')   // Should return user JSON
```

### 2. Login with Invalid Credentials ❌

**Steps**:
1. Go to login page
2. Enter invalid username/password
3. Click "Login"

**Expected Result**:
- Error toast notification (red, top-right)
- Error message displayed: "Invalid username or password"
- Stays on login page
- No data stored

### 3. Login with Non-McDonald's User ❌

**Steps**:
1. Go to login page
2. Enter credentials for a user where `isMcDUser` is not "True"
3. Click "Login"

**Expected Result**:
- Error toast notification (red)
- Error message: "Invalid User. Only McDonald's users can access this application."
- Stays on login page

### 4. Remember Me & Auto-Login ✅

**Steps**:
1. Go to login page
2. Check the "Remember me" checkbox
3. Enter valid credentials
4. Login successfully
5. Close the browser completely
6. Reopen browser to `http://localhost:5173`

**Expected Result**:
- Login page appears briefly
- Auto-login kicks in
- Success toast: "Welcome back, [Name]!"
- Automatically redirects to dashboard
- No need to enter credentials again

**Check**:
```javascript
// IndexedDB should contain credentials
// Open Application tab in DevTools -> IndexedDB -> mcd-uco-secure
```

### 5. Environment Switching (Dev Mode Only) 🔧

**Steps**:
1. On login page, scroll down
2. You should see "Development Mode - Switch Environment"
3. Click "Production" button

**Expected Result**:
- Environment indicator changes to green "PRODUCTION"
- Backend will now use production UCO API
- Setting persisted in localStorage

**Check**:
```javascript
localStorage.getItem('api_environment')  // Should be 'production'
```

### 6. Token Expiry & Auto-Logout ⏰

**Steps**:
1. Login successfully
2. Open browser console
3. Manually change login time to simulate expiry:
```javascript
// Set login time to 2 days ago
const twoDaysAgo = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString()
localStorage.setItem('login_time', twoDaysAgo)
```
4. Navigate to any route (refresh page or click a link)

**Expected Result**:
- Router guard detects expired token
- Auto-logout triggered
- Storage cleared
- Redirected to login page

### 7. Logout Flow 🚪

**Steps**:
1. Login successfully
2. Navigate to dashboard
3. Trigger logout (you'll need to implement logout button in UI, or use console):
```javascript
// In browser console
const { useAuth } = await import('/src/composables/useAuth.ts')
const auth = useAuth()
await auth.logout()
```

**Expected Result**:
- "Logged out successfully" toast (blue info)
- All localStorage cleared
- IndexedDB credentials cleared
- Redirected to login page

**Check**:
```javascript
localStorage.getItem('auth_token')  // Should be null
localStorage.getItem('auth_user')   // Should be null
```

### 8. Protected Routes 🔒

**Steps**:
1. Make sure you're logged out
2. Try to access: `http://localhost:5173/home/dashboard`

**Expected Result**:
- Route guard blocks access
- Automatically redirected to `/login`

**Then**:
1. Login successfully
2. Try to access: `http://localhost:5173/login`

**Expected Result**:
- Already logged in, redirected to `/home/dashboard`

### 9. API Interceptor - 401 Handling 🔐

**Steps**:
1. Login successfully
2. Open browser console
3. Corrupt the token:
```javascript
localStorage.setItem('auth_token', 'invalid-token-xyz')
```
4. Make any API request (or refresh page if routes check token)

**Expected Result**:
- API returns 401 Unauthorized
- Response interceptor detects it
- Auto-logout triggered
- Error toast: "Session expired. Please login again."
- Redirected to login

### 10. Offline Detection 📡

**Steps**:
1. Login successfully
2. Open DevTools -> Network tab
3. Set network to "Offline"

**Expected Result**:
- App should detect offline status
- `uiStore.isOnline` becomes `false`

**Then**:
1. Set network back to "Online"

**Expected Result**:
- `uiStore.isOnline` becomes `true`

## Testing with Backend Logs

The backend logs all authentication events. Check your backend terminal:

**Successful Login**:
```
[info] Login attempt for user: testuser
[info] Login successful for user: testuser (John Doe)
```

**Failed Login**:
```
[info] Login attempt for user: wronguser
[error] Login failed for user wronguser: { status: 400, message: '...' }
```

**Non-McDonald's User**:
```
[info] Login attempt for user: regularuser
[warn] Login rejected: User regularuser is not a McDonald's user
```

**Logout**:
```
[info] Logout request received
[info] Logout successful
```

## API Endpoints to Test

### Health Check (No Auth Required)
```bash
curl http://localhost:3000/api/health
```

**Expected**:
```json
{
  "success": true,
  "message": "McDonald's UCO API is running",
  "timestamp": "2025-12-24T..."
}
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass"}'
```

**Expected** (if valid):
```json
{
  "success": true,
  "data": {
    "access_token": "...",
    "firstName": "John",
    "lastName": "Doe",
    "isMcDUser": "True",
    ...
  }
}
```

### Verify Token
```bash
curl http://localhost:3000/api/auth/verify \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected**:
```json
{
  "success": true,
  "message": "Token is valid"
}
```

### Logout
```bash
curl -X POST http://localhost:3000/api/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected**:
```json
{
  "success": true,
  "message": "Logout successful"
}
```

## Common Issues & Solutions

### Issue: "Authorization token required"
**Cause**: Token not being sent in request
**Solution**: Check that token is in localStorage and API client interceptor is working

### Issue: Auto-login not working
**Cause**: Credentials not saved in IndexedDB
**Solution**: Make sure "Remember me" was checked during login

### Issue: "Invalid User" error
**Cause**: User's `isMcDUser` field is not "True"
**Solution**: Use a different test account that is a McDonald's user

### Issue: CORS errors
**Cause**: Backend CORS not configured for frontend URL
**Solution**: Check `backend/.env` has correct `FRONTEND_URL=http://localhost:5173`

### Issue: 404 on auth endpoints
**Cause**: Backend not running or routes not registered
**Solution**:
1. Check backend is running on port 3000
2. Check `backend/src/routes/index.ts` has auth routes imported
3. Restart backend server

## Browser DevTools Tips

### Check Auth State
```javascript
// Open Console tab
const { useAuthStore } = await import('/src/stores/auth.ts')
const { default: { createPinia } } = await import('pinia')
const pinia = createPinia()
const authStore = useAuthStore(pinia)
console.log('Authenticated:', authStore.isAuthenticated)
console.log('User:', authStore.user)
console.log('Token:', authStore.token)
```

### Monitor Network Requests
1. Open DevTools -> Network tab
2. Filter by "Fetch/XHR"
3. Look for:
   - `POST /api/auth/login`
   - `POST /api/auth/logout`
   - `GET /api/auth/verify`
4. Check headers for `Authorization: Bearer ...`

### Check localStorage
1. Open DevTools -> Application tab
2. Expand "Local Storage"
3. Click on `http://localhost:5173`
4. Look for:
   - `auth_token`
   - `auth_user`
   - `login_time`
   - `api_environment`

### Check IndexedDB
1. Open DevTools -> Application tab
2. Expand "IndexedDB"
3. Expand "mcd-uco-secure"
4. Click "credentials"
5. Should see saved credentials if "Remember me" was used

## Success Criteria

✅ Login works with valid credentials
✅ Login fails with invalid credentials
✅ Non-McDonald's users are rejected
✅ Token is stored and persisted
✅ Remember me saves credentials
✅ Auto-login works after browser restart
✅ Logout clears all data
✅ Protected routes require authentication
✅ Token expiry triggers auto-logout
✅ 401 responses trigger auto-logout
✅ Environment switching works
✅ Toast notifications appear correctly
✅ Loading states display properly

## Next Steps

After verifying authentication works:

1. Proceed to Phase 3: Core API Integration
2. Implement remaining API endpoints
3. Build out dashboard with real data
4. Implement collection and delivery screens

---

**Document Version**: 1.0
**Last Updated**: December 24, 2025
**Phase**: 2 - Authentication
