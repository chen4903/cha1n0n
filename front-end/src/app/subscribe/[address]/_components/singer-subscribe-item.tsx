"use client";

import Image from "next/image";
import Link from "next/link";
import { formatDate } from "~/utils";

import { motion, useMotionTemplate, useMotionValue } from "framer-motion";

import { Icons } from "./icons";

import { Avatar } from "@nextui-org/react";
import { useRouter } from "next/navigation";
import hero from "public/images/hero-card.png";

export default function SingerSubscribeItem({ title }: { title: string }) {
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  return (
    <div className="group relative flex flex-col items-center rounded-xl border-zinc-800 p-2">
      <motion.div
        className="pointer-events-none absolute -inset-px rounded-xl opacity-0 transition duration-300 group-hover:opacity-100"
        style={{
          background: useMotionTemplate`
            radial-gradient(
              650px circle at ${mouseX}px ${mouseY}px,
              rgba(255,255,255,0.1),
              transparent 80%
            )
          `,
        }}
      />
      <Avatar
        isBordered
        radius="sm"
        size="lg"
        src="https://i.pravatar.cc/150?u=a04258a2462d826712d"
      />
    </div>
  );
}
