/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#258AFF',
        'primary-light': '#E3F2FF',
        secondary: '#52CB00',
        'widget-orange': 'rgba(244, 152, 35, 0.7)',
        'widget-pink': 'rgba(212, 97, 210, 0.7)',
        'widget-blue': 'rgba(36, 200, 248, 0.7)',
        'widget-grey': 'rgba(133, 155, 144, 0.3)',
      },
      borderRadius: {
        '15': '15px',
        '30': '30px',
        '100': '100px',
      },
      backgroundImage: {
        'app-bg': "url('/assets/bg.jpg')",
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
