import type React from "react";
import { useState } from "react";

import styles from "./ColorPicker.module.css";

import { hexRGBtoNumber } from "@/utils.ts";
import Sketch from "@uiw/react-color-sketch";

export interface ColorPickerProps {
  onColorSelect: (color: number) => void;
  color: number;
}

const ColorPicker: React.FC<ColorPickerProps> = ({
  onColorSelect,
  color: selectedColor,
}) => {
  const [hex, setHex] = useState("#fff");

  const handleChange = (color: any) => {
    onColorSelect(Number.parseInt(color.hex.replace("#", ""), 16));
  };

  return (
    <div className={"pickerPanel"}>
      <Sketch
        style={{ marginLeft: 20, width: "100%", height: "100%" }} // Full width and height
        color={hex}
        disableAlpha={false}
        onChange={(color) => {
          onColorSelect(hexRGBtoNumber(color.hex));
          setHex(color.hex);
        }}
      />
    </div>
  );
};

export default ColorPicker;
