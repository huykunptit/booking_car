/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        stitch: {
          background: '#f8f9fa',
          primary: '#002653',
          'primary-container': '#1a3c6e',
          secondary: '#a83900',
          accent: '#fe6a2b',
          'on-surface': '#191c1d',
          'on-surface-variant': '#43474f',
          'outline': '#73777f',
          'outline-variant': '#c4c6d0',
          'surface-container-lowest': '#ffffff',
          'surface-container-low': '#f3f4f5',
          'surface-container': '#edeeef',
          'surface-container-high': '#e7e8e9',
          'surface-container-highest': '#e1e3e4',
        }
      },
      fontFamily: {
        sans: ['"Be Vietnam Pro"', 'sans-serif'],
      },
      borderRadius: {
        'stitch-md': '12px',
        'stitch-lg': '16px',
        'stitch-xl': '24px',
      },
      boxShadow: {
        'stitch-ambient': '0px 12px 32px rgba(26, 60, 110, 0.06)',
      }
    },
  },
  plugins: [],
}
