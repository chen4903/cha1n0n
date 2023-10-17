import { type Config } from "tailwindcss";
import { fontFamily } from "tailwindcss/defaultTheme";

export default {
  content: ["./src/**/*.tsx"],
  theme: {
    screens: {
      sm: "100px",
      md: "768px",
      lg: "1024px",
      xl: "1280px",
    },
    lineHeight: {
      relaxed: "1.8",
    },
    extend: {
      colors: {
        primary: "#fff",
        foreground: "#d4d4d4",
        background: "#08070B",
        input: "#131415",
        muidground: "#18181B",
      },
      fontFamily: {
        sans: ["var(--font-sans)", ...fontFamily.sans],
        poppins: "var(--font-default)",
        title: "var(--font-title)",
      },
    },
  },
  plugins: [],
} satisfies Config;
