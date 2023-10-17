"use client";

import hero from "public/images/hero-card.png";

import React from "react";
import Image from "next/image";
import { ModalButton } from "./modal";

import {
  Card,
  CardHeader,
  CardBody,
  CardFooter,
  Divider,
  Link,
  Button,
} from "@nextui-org/react";

export function SingerCard() {
  return (
    <Card isFooterBlurred radius="lg" className="w-64 border-none p-6">
      <Image
        alt="Woman listing to music"
        className="rounded-lg"
        src={hero}
        style={{
          width: "100%",
          height: "auto",
        }}
        placeholder="blur"
        blurDataURL={hero.blurDataURL}
      />
      <CardFooter className="border-1 rounded-large shadow-small absolute bottom-2 left-1/2 z-10 w-44 -translate-x-1/2 -translate-y-1/2 justify-between overflow-hidden border-white/20 py-1 before:rounded-xl before:bg-white/10">
        <p className="text-tiny text-white/80">Available soon.</p>
        <Button
          className="text-tiny bg-black/20 text-white"
          variant="flat"
          color="default"
          radius="lg"
          size="sm"
        >
          <ModalButton text="Subscribe"/>
        </Button>
      </CardFooter>
    </Card>
  );
}
