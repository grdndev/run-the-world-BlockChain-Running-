/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
    presets: [require("nativewind/preset")],
    theme: {
        extend: {
            colors: {
                'rtw-navy': '#0B1221',
                'rtw-gold': '#FFB800',
                'rtw-orange': '#FF8A00',
                'rtw-dark': '#05080F',
            },
            borderRadius: {
                '24': '24px',
            }
        },
    },
    plugins: [],
}
