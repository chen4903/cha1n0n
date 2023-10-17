"use client";

import { useRef } from "react";
import { useAtom } from "jotai";
import { roleAtom } from "~/utils/atom";
import { usePathname } from "next/navigation";

import clsx from "clsx";
import Link from "next/link";
import Lottie from "lottie-react";
import homeIcon from "public/icons/static/home.json";
import UserNav from "./user";
import SingerNav from "./singer";

export function Navigation() {
  const homeRef = useRef<any>();

  const pathname = usePathname();

  const [role] = useAtom(roleAtom);

  return (
    <nav className="mb-4 hidden flex-col lg:flex">
      <Link
        href="/"
        onMouseEnter={() => homeRef.current?.play()}
        onMouseLeave={() => homeRef.current?.stop()}
        className={clsx(
          "text-foreground flex items-center gap-2 rounded-lg px-2.5 py-2 duration-300 hover:bg-neutral-800",
          {
            "text-primary bg-neutral-800": pathname === "/",
          },
        )}
      >
        <Lottie
          lottieRef={homeRef}
          animationData={homeIcon}
          style={{ width: 24, height: 24 }}
          autoplay={false}
          loop={false}
        />
        <span className="text-sm capitalize">home</span>
      </Link>
      {role === "user" ? <UserNav /> : null}
      {/* {role === "singer" ? <SingerNav /> : null} */}
    </nav>
  );
}
