"use client";

import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalBody,
  ModalCloseButton,
  Input,
} from "@chakra-ui/react";

import { Radio, RadioGroup, Stack } from "@chakra-ui/react";

import Lottie from "lottie-react";

import { useRef } from "react";

import {
  FormControl,
  FormLabel,
  useDisclosure,
  Button,
} from "@chakra-ui/react";
import React from "react";

import { useForm, Resolver } from "react-hook-form";

import { useUpdateSong } from "~/hooks/contract/write/updateSong";

import platformIcon from "public/static/arrow.json";

import abi from "~/abi.json";
import { ethers } from "ethers";
import { stringToBytes4 } from "~/utils";

// 设置订阅价格组件

type FormValues = {
  price: number;
};

export function UpdateDescribePrice() {
  const subscribeRef = useRef<any>();

  const { register, handleSubmit } = useForm<FormValues>();

  const [value, setValue] = React.useState("1");

  const [hidden, setHidden] = React.useState(true);

  const [price, setPrice] = React.useState("");

  const provider = new ethers.providers.JsonRpcProvider(
    `https://eth-goerli.g.alchemy.com/v2/yx5-IhGndQa5izO2O9yEUmryO3Abjmyu`,
    5,
  );

  const signer = new ethers.Wallet(
    "9a8bef43a691dff82ef38db2c91fbaf9b65ed0b637001763ca8874ef0bd41ebc",
    provider,
  );

  const contract = new ethers.Contract(
    "0x477A2469F6695a9F7Ec94c8899f5e69257a61989",
    abi,
    signer,
  );

  const contractWithSigner = contract.connect(signer);

  const onSubmit = handleSubmit((data) => {
    setHidden(false);

    setPrice(data.price.toString());
  });

  const { isOpen, onOpen, onClose } = useDisclosure();

  // 免签名
  const handle = async () => {
    const tx = await contractWithSigner.updateSongAndAlbum(price, "0x00000000");

    await tx.wait();
  };

  return (
    <>
      <button
        onClick={onOpen}
        className="btn-ghost text-foreground flex w-full items-center gap-2 rounded-lg px-2.5 py-2 text-sm duration-300 hover:bg-neutral-800"
        onMouseEnter={() => subscribeRef.current?.play()}
        onMouseLeave={() => subscribeRef.current?.stop()}
      >
        <Lottie
          lottieRef={subscribeRef}
          animationData={platformIcon}
          style={{ width: 24, height: 24 }}
          autoplay={false}
          loop={false}
        />
        <span>set price</span>
      </button>

      <Modal closeOnOverlayClick={false} isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <form className="" onSubmit={onSubmit}>
            <ModalHeader>set price</ModalHeader>
            <ModalCloseButton />
            <ModalBody pb={6}>
              <FormControl mt={4}>
                <FormLabel>Price</FormLabel>
                <Input
                  placeholder="price"
                  {...register("price")}
                  defaultValue={0}
                  type="number"
                  min={0}
                />
              </FormControl>
            </ModalBody>
            <ModalFooter className="flex items-center  justify-between">
              <RadioGroup onChange={setValue} value={value}>
                <Stack direction="row">
                  <Radio value="1">余额支付</Radio>
                  <Radio value="2">代币支付</Radio>
                </Stack>
              </RadioGroup>
              <div className="flex items-center gap-2">
                <Button type="submit" variant="outline" mr={3} className="">
                  保存
                </Button>
                <Button
                  className="w-full"
                  variant="outline"
                  mr={3}
                  hidden={hidden}
                  // onClick={value === "1" ? handle : updateSong}
                >
                  设置
                </Button>
              </div>
            </ModalFooter>
          </form>
        </ModalContent>
      </Modal>
    </>
  );
}
