import fluid, { extract } from "fluid-tailwind";
import tailwindcssAnimate from "tailwindcss-animate";

export default {
  darkMode: ["class"],
  content: {
    files: ["./pages/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./app/**/*.{ts,tsx}", "./src/**/*.{ts,tsx}"],
    extract,
  },
  prefix: "",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      fontFamily: {
        silkscreen: {
          DEFAULT: ["Silkscreen", "sans-serif"],
        },
        roboto: {
          DEFAULT: ["Roboto", "sans-serif"],
          mono: ["Roboto Mono", "monospace"],
        },
      },
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
        "fade-in-out": {
          "0%": {
            opacity: "0",
            transform: "translate(-50%, -10px)",
          },
          "50%": {
            opacity: "1",
            transform: "translate(-50%, 0)",
          },
          "100%": {
            opacity: "0",
            transform: "translate(-50%, -10px)",
          },
        },
        "slide-open": {
          from: { transform: "scaleX(0)" },
          to: { transform: "scaleX(1)" },
        },
        "slide-close": {
          from: { transform: "scaleX(1)" },
          to: { transform: "scaleX(0)" },
        },
      },
      animation: {
        "fade-in-out": "fade-in-out 1s ease-in-out",
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
        "slide-open": "slide-open 0.3s ease-out forwards",
        "slide-close": "slide-close 0.3s ease-in forwards",
      },
      transformOrigin: {
        center: "center",
        left: "left",
        right: "right",
      },
    },
  },
  plugins: [fluid, tailwindcssAnimate],
};
