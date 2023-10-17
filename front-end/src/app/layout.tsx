import "~/styles/globals.css";

import { headers } from "next/headers";
import { TRPCReactProvider } from "~/trpc/react";
import { Poppins, Kanit } from "next/font/google";
import { Provider } from "./_components/provider";
import { AnimateEnter } from "./_components/animate-enter";

import type { Metadata } from "next";

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-default",
});

const kanit = Kanit({
  subsets: ["latin"],
  weight: ["400"],
  variable: "--font-title",
});

export const metadata: Metadata = {
  authors: [{ name: "Cha1nOn Team", url: "" }],
  category: "Cha1nOn",
  creator: "Cha1nOn",
  description: "Cha1nOn Music DAPP",
  title: "Cha1nOn",
  icons: {
    apple: "/favicon.ico",
    icon: "/favicon.ico",
    shortcut: "/favicon.ico",
  },
  keywords: ["智能合约", "Music Dapp", "Cha1nOn", "去中心化音乐DAPP", "Nextjs"],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body
        className={`font-sans ${poppins.variable} ${kanit.variable} bg-background font-poppins relative flex min-h-screen justify-center outline-none`}
      >
        <TRPCReactProvider headers={headers()}>
          <Provider>
            <AnimateEnter className="max-w-9xl mx-auto flex flex-col px-8 lg:flex-row lg:gap-10 lg:py-20">
              {children}
            </AnimateEnter>
          </Provider>
        </TRPCReactProvider>
      </body>
    </html>
  );
}
