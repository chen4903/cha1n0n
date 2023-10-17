"use client";

import { useRef } from "react";
import { ethers } from "ethers";
import { useAccount } from "wagmi";
import { motion } from "framer-motion";
import { usePathname } from "next/navigation";

import clsx from "clsx";
import Link from "next/link";
import Lottie from "lottie-react";
import { stringToBytes4 } from "~/utils";
import marketIcon from "public/icons/static/market.json";
import platformIcon from "public/icons/static/arrow.json";
import subscribeIcon from "public/icons/static/subscribe.json";
import { Divider } from "../../divider";
import { UpdateDescribePrice } from "./update-describe-price";
import { UpdateAlbum } from "./update-album";

export default function SingerNav() {
  const { address } = useAccount();

  const subscribeRef = useRef<any>();

  const pathname = usePathname();

  return (
    <motion.div
      key="modal"
      exit={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.8 }}
      initial={{ opacity: 0, y: 10 }}
      className="space-y-1"
    >
      <Link
        href={`/singer/${address}`}
        onMouseEnter={() => subscribeRef.current?.play()}
        onMouseLeave={() => subscribeRef.current?.stop()}
        className={clsx(
          "text-foreground flex items-center gap-2 rounded-lg px-2.5 py-2 duration-300 hover:bg-neutral-800",
          {
            "text-primary bg-neutral-800": pathname === "/singer",
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
        <span className="text-sm capitalize">my music</span>
      </Link>
      <Divider />
      <div className="space-y-4 pt-2">
        <UpdateAlbum />
        <UpdateDescribePrice />
      </div>
    </motion.div>
  );
}
