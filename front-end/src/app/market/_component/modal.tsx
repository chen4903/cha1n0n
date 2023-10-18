"use client";

import clsx from "clsx";
import React from "react";
import Lottie from "lottie-react";
import { RadioGroup, Radio } from "@nextui-org/react";
import arrowIcon from "public/icons/static/arrow.json";
import { Button, DropdownItem } from "@nextui-org/react";
import { Modal, ModalContent, ModalHeader } from "@nextui-org/react";
import { Tabs, Tab, Card, CardBody, CardHeader } from "@nextui-org/react";
import { useDisclosure, ModalBody, ModalFooter } from "@nextui-org/react";

import { useAccount } from "wagmi";
import { toast } from "react-toastify";
import { cn, isEOAAddress, isBytes4 } from "~/utils";
import { useForm, Resolver } from "react-hook-form";
import { useHooks } from "~/app/_components/provider";
import { useMarketLengthMusic } from "~/hooks/read/marketLength";
import { useMarketLengthMusicAlbum } from "~/hooks/read/marketLengthAlbum";
import { Dropdown, DropdownTrigger, DropdownMenu } from "@nextui-org/react";

export function ModalButton({ text }: { text: string }) {
  const { address } = useAccount();

  const items = [
    {
      key: "system",
      label: "system",
    },
    {
      key: "self",
      label: "self",
    },
  ];

  return (
    <>
      <Dropdown>
        <DropdownTrigger>
          <button className="h-full w-full border-none bg-transparent outline-none">
            {text}
          </button>
        </DropdownTrigger>
        <DropdownMenu
          aria-label="subscribe"
          items={items}
          className="space-y-2"
        >
          {items.map((item) => (
            <DropdownItem
              key={item.key}
              color={item.key === "delete" ? "danger" : "default"}
              className={item.key === "delete" ? "text-danger" : ""}
            >
              {item.label}
            </DropdownItem>
          ))}
        </DropdownMenu>
      </Dropdown>
    </>
  );
}
