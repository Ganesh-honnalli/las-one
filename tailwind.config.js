/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        shelf: {
          dark: '#0f261c',
          navy: '#131921',
          forest: '#1b4332',
          emerald: '#2d6a4f',
          lightgreen: '#d8f3dc',
          cream: '#fdfbf7',
          gold: '#f59e0b',
          goldhover: '#d97706',
          yellow: '#febd69',
          orange: '#f97316'
        }
      }
    },
  },
  plugins: [],
}
