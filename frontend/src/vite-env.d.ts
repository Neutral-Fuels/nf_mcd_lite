/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_BACKEND_URL: string
  readonly VITE_APP_VERSION: string
  readonly VITE_APP_CODE: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
