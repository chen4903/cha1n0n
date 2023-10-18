"use client";

import React from "react";
import Image from "next/image";
import albumImageOne from "public/images/album-1.jpg";
import albumImageTwo from "public/images/album-2.jpg";
import albumImageThree from "public/images/album-3.jpg";
import albumImageFour from "public/images/album-4.jpg";
import albumImageFive from "public/images/album-5.jpg";
import { Card, CardHeader, Link } from "@nextui-org/react";
import { CardBody, CardFooter, Divider } from "@nextui-org/react";

export function AlbumCard({ name, index }: { name: string; index: number }) {
  const ImagesArray = [
    albumImageOne,
    albumImageTwo,
    albumImageThree,
    albumImageFour,
    albumImageFive,
  ];

  const ImageIndex = index % 6;

  return (
    <Card className="w-72 border-none px-4 py-2" key={name}>
      <CardHeader className="flex gap-3">
        <div className="flex flex-col">
          <p className="text-md">{name}</p>
        </div>
      </CardHeader>
      <Divider />
      <CardBody>
        <Image
          style={{
            width: "auto",
            height: "auto",
          }}
          placeholder="blur"
          blurDataURL={ImagesArray[ImageIndex]!.blurDataURL}
          src={ImagesArray[ImageIndex]!}
          alt="1"
        />
      </CardBody>
      <CardFooter className="flex items-center justify-center">
        <Link
          isExternal
          showAnchorIcon
          href={`/music/${name}?index=${ImageIndex}`}
        >
          Visit now
        </Link>
      </CardFooter>
    </Card>
  );
}
