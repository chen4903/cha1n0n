"use client";

import { useRef } from "react";
import { motion } from "framer-motion";
import { usePathname } from "next/navigation";

import clsx from "clsx";
import Link from "next/link";
import Lottie from "lottie-react";
import { Divider } from "../../divider";
import platformIcon from "public/icons/static/projects.json";
import subscribeIcon from "public/icons/static/subscribe.json";

export default function UserNav() {
  const subscribeRef = useRef<any>();

  const platformRef = useRef<any>();

  const pathname = usePathname();
  return (
    <motion.div
      exit={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.8 }}
      className="sapce-y-1.5"
    >
      <Link
        href="/subscribe"
        onMouseEnter={() => subscribeRef.current?.play()}
        onMouseLeave={() => subscribeRef.current?.stop()}
        className={clsx(
          "text-foreground flex items-center gap-2 rounded-lg px-2.5 py-2 duration-300 hover:bg-neutral-800",
          {
            "text-primary bg-neutral-800": pathname === "/subscribe",
          },
        )}
      >
        <Lottie
          lottieRef={subscribeRef}
          animationData={subscribeIcon}
          style={{ width: 24, height: 24 }}
          autoplay={false}
          loop={false}
        />
        <span className="text-sm capitalize">subscribe</span>
      </Link>
      <Link
        href="/platform"
        onMouseEnter={() => platformRef.current?.play()}
        onMouseLeave={() => platformRef.current?.stop()}
        className={clsx(
          "text-foreground flex items-center gap-2 rounded-lg px-2.5 py-2 duration-300 hover:bg-neutral-800",
          {
            "text-primary bg-neutral-800": pathname === "/platform",
          },
        )}
      >
        <Lottie
          lottieRef={platformRef}
          animationData={platformIcon}
          style={{ width: 24, height: 24 }}
          autoplay={false}
          loop={false}
        />
        <span className="text-sm">Platform</span>
      </Link>
    </motion.div>
  );
}
