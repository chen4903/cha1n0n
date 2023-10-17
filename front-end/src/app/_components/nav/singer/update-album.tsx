"use client";

import React from "react";
import { ethers } from "ethers";
import { toast } from "react-toastify";
import { motion } from "framer-motion";
import { stringToBytes4 } from "~/utils";
import { BadgePlusIcon } from "lucide-react";
import { useForm, Resolver } from "react-hook-form";

import { useUpdateAlbumPrice } from "~/hooks/contract/write/updateAlbumPrice";

type FormValues = {
  price: number;
  name: string;
};

export function UpdateAlbum() {
  const { register, handleSubmit } = useForm<FormValues>();

  const [value, setValue] = React.useState("1");

  const [name, setName] = React.useState("");

  const [hidden, setHidden] = React.useState(true);

  const [price, setPrice] = React.useState("");

  const onSubmit = handleSubmit((data) => {
    setHidden(false);
    setPrice(data.name);
    setPrice(data.price.toString());
  });

  const { isOpen, onOpen, onClose } = useDisclosure();

  const { updateAlbumPrice, updateAlbumPriceLoading } = useUpdateAlbumPrice({
    price: price,
    name: name,
    onSetSongSuccess: () => {
      toast.success("🦄 Please check input", {
        position: "top-right",
        autoClose: 5000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      });
    },
  });

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

  const handle = async () => {
    const tx = await contractWithSigner.updateSongAndAlbum(
      price,
      stringToBytes4(name),
    );
    await tx.wait();
  };

  return (
    <>
      <motion.button
        onClick={onOpen}
        className="btn-ghost text-foreground flex w-full items-center gap-2 rounded-lg px-2.5 py-2 text-sm duration-300 hover:bg-neutral-800"
      >
        <motion.div animate={{ rotate: [0, 0, 270, 270, 0] }}>
          <BadgePlusIcon />
        </motion.div>
        set album
      </motion.button>

      <Modal closeOnOverlayClick={false} isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <form className="" onSubmit={onSubmit}>
            <ModalHeader>create or update</ModalHeader>
            <ModalCloseButton />
            <ModalBody pb={6}>
              <FormControl mt={4}>
                <FormLabel>Name</FormLabel>
                <Input placeholder="price" {...register("name")} required />
              </FormControl>
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
                  onClick={value === "1" ? handle : updateAlbumPrice}
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
