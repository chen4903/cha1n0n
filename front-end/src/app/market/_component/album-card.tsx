"use client";

import hero from "public/images/hero-card.png";

import React from "react";
import {
  Card,
  CardHeader,
  CardBody,
  CardFooter,
  Divider,
  Link,
  Button,
} from "@nextui-org/react";
import Image from "next/image";

export function AlbumCard() {
  return (
    <Card className="border-none w-72 px-4 py-2">
      <CardHeader className="flex gap-3">
        <div className="flex flex-col">
          <p className="text-md">Name</p>
          <p className="text-default-400 text-xs">创建时间</p>
        </div>
      </CardHeader>
      <Divider />
      <CardBody>
        <p>Make beautiful websites regardless of your design experience.</p>
      </CardBody>
      <Divider />
      <CardFooter>
        <Link
          isExternal
          showAnchorIcon
          href="https://github.com/nextui-org/nextui"
        >
          Visit now
        </Link>
      </CardFooter>
    </Card>
  );
}
