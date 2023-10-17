import clsx from "clsx";
import React from "react";
import Lottie from "lottie-react";
import { RadioGroup, Radio } from "@nextui-org/react";
import arrowIcon from "public/icons/static/arrow.json";
import { Button, Checkbox, Input, Link } from "@nextui-org/react";
import { Modal, ModalContent, ModalHeader } from "@nextui-org/react";
import { Tabs, Tab, Card, CardBody, CardHeader } from "@nextui-org/react";
import { useDisclosure, ModalBody, ModalFooter } from "@nextui-org/react";

import { cn, isEOAAddress } from "~/utils";
import { toast } from "react-toastify";
import { useForm, Resolver } from "react-hook-form";
import { useHooks } from "~/app/_components/provider";
import { useMarketLengthMusic } from "~/hooks/read/marketLength";

type FormValues = {
  singer: string;
};

export function MarketLenth() {
  const arrowRef = React.useRef<any>();

  const { signer } = useHooks();

  const [isHidden, setIsHidden] = React.useState(true);

  const [singer, setSinger] = React.useState("");

  const [selected, setSelected] = React.useState("music");

  const [payType, setPayType] = React.useState("system");

  const { isOpen, onOpen, onOpenChange } = useDisclosure();

  const { register, handleSubmit } = useForm<FormValues>();

  const handleRadioChange = (value: string) => {
    setPayType(value);
    console.log(value);
  };

  const handleSelectionChange = (key: React.Key) => {
    if (typeof key === "string") {
      setSelected(key);
    }
  };

  const handleMarketLengthMusic = async (singer: string) => {
    const result = await signer.marketLength(
      singer,
      Buffer.from("00000000", "hex"),
    );
    console.log(result);
  };

  const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    handleMarketLengthMusic(singer);
  };

  const onSubmit = handleSubmit((data) => {
    console.log("提交", data.singer);
    if (!isEOAAddress(data.singer)) {
      toast.error("🦄 Please check input", {
        position: "top-right",
        autoClose: 5000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      });
      return;
    }
    setSinger(data.singer);
    setIsHidden(false);
    // handleMarketLengthMusic(data.singer);
  });

  const { marketLengthMusic } = useMarketLengthMusic({ singer: singer });

  const handleIshidden = () => {
    setIsHidden(true);
  };

  const handleUseMarketLengthMusic = () => {
    toast(`"🦄 ${marketLengthMusic}"`, {
      position: "top-right",
      autoClose: 5000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: true,
      progress: undefined,
      theme: "dark",
    });
  };

  return (
    <>
      <button
        onClick={onOpen}
        onMouseEnter={() => arrowRef.current?.play()}
        onMouseLeave={() => arrowRef.current?.stop()}
        className={clsx(
          "flex items-center gap-2 rounded-lg px-2.5 py-2 text-foreground duration-300 hover:bg-neutral-800  hover:text-primary",
        )}
      >
        <Lottie
          lottieRef={arrowRef}
          animationData={arrowIcon}
          style={{ width: 20, height: 20 }}
          autoplay={false}
          loop={false}
        />
        <span className="text-sm capitalize">quary MarketLenth</span>
      </button>
      <Modal
        isOpen={isOpen}
        onOpenChange={onOpenChange}
        placement="top-center"
        isDismissable={false}
        size="lg"
      >
        <ModalContent>
          {(onClose) => (
            <>
              <ModalHeader className="flex flex-col gap-1 capitalize">
                quary MarketLenth
              </ModalHeader>
              <ModalBody>
                <Tabs
                  fullWidth
                  size="md"
                  aria-label="Tabs form"
                  selectedKey={selected}
                  onSelectionChange={handleSelectionChange}
                >
                  <Tab key="music" title="Music">
                    <form onSubmit={onSubmit}>
                      <Input
                        autoFocus
                        label="Singer Address"
                        placeholder="Enter singer address"
                        variant="bordered"
                        required
                        min={42}
                        {...register("singer")}
                      />
                      <ModalFooter className="items-center justify-between pl-0 pt-6">
                        <RadioGroup
                          orientation="horizontal"
                          onValueChange={handleRadioChange}
                          defaultValue="system"
                        >
                          <Radio value="system">system</Radio>
                          <Radio value="self" color="secondary">
                            self
                          </Radio>
                        </RadioGroup>
                        <div className="flex items-center gap-4">
                          <Button
                            color="danger"
                            size="sm"
                            variant="flat"
                            onPress={onClose}
                          >
                            Close
                          </Button>
                          <Button
                            color="primary"
                            size="sm"
                            type="submit"
                            className={cn(
                              "bg-pink-600 text-white shadow-lg",
                              !isHidden ? "hidden" : "",
                            )}
                          >
                            Save
                          </Button>
                          <Button
                            color="primary"
                            size="sm"
                            onClick={handleIshidden}
                            className={cn(
                              "bg-pink-600 text-white shadow-lg",
                              isHidden ? "hidden" : "",
                            )}
                          >
                            rewrite
                          </Button>
                          <Button
                            color="default"
                            size="sm"
                            onClick={
                              payType === "system"
                                ? handleClick
                                : handleUseMarketLengthMusic
                            }
                            className={cn(
                              " bg-gradient-to-tr from-pink-500 to-yellow-500 text-white shadow-lg",
                              isHidden ? "hidden" : "",
                            )}
                          >
                            Start
                          </Button>
                        </div>
                      </ModalFooter>
                    </form>
                  </Tab>
                  <Tab key="album" title="Album">
                    <Input
                      autoFocus
                      label="Singer Address"
                      variant="bordered"
                    />
                    <Input
                      label="Password"
                      placeholder="Enter your password"
                      type="password"
                      variant="bordered"
                    />
                    <ModalFooter>
                      <Button color="danger" variant="flat" onPress={onClose}>
                        Close
                      </Button>
                      <Button color="primary" onPress={onClose}>
                        Sign in
                      </Button>
                    </ModalFooter>
                  </Tab>
                </Tabs>
              </ModalBody>
            </>
          )}
        </ModalContent>
      </Modal>
    </>
  );
}
