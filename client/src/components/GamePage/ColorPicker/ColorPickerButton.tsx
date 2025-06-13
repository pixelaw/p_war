import CustomButton from "@/components/CustomButton/CustomButton.tsx";
import { numberToHexRGB } from "@/utils.ts";
import type React from "react";

export interface ColorPickerButtonProps {
  onClick: () => void;
  onSecondary: () => void;
  color: number;
  selected: boolean;
}

const ColorPickerButton: React.FC<ColorPickerButtonProps> = ({
  onClick,
  onSecondary,
  color,
  selected,
}) => {
  return (
    <CustomButton
      onClick={onClick}
      onSecondary={onSecondary}
      selected={selected}
    >
      <span
        style={{
          fontSize: "4rem",
          fontFamily: "'Noto Emoji', sans-serif",
          transform: "translate(0, 0)",
          color: numberToHexRGB(color),
          textShadow: `0 0 0 ${numberToHexRGB(color)}`,
        }}
      >
        🎨
      </span>
    </CustomButton>
  );
};

export default ColorPickerButton;
