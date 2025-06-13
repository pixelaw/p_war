import { hexRGBtoNumber, numberToHexRGB } from "@/utils.ts";
import styles from "./SimpleColorPicker.module.css";

const colors = [
  "#FF0000",
  "#FF7F00",
  "#FFFF00",
  "#00FF00",
  "#0000FF",
  "#4B0082",
  "#9400D3",
  "#FFFFFF", // white
  "#000000", // black
];

export interface ColorPickerProps {
  onColorSelect: (color: number) => void;
  color: number;
}

const SimpleColorPicker: React.FC<ColorPickerProps> = ({
  onColorSelect,
  color: selectedColor,
}) => {
  const selectedColorHex = numberToHexRGB(selectedColor);

  return (
    <div className={"pickerPanel"}>
      {colors.map((color) => (
        <button
          type={"button"}
          key={color}
          style={{
            backgroundColor: color,
            outline: selectedColorHex === color ? "4px solid black" : "none",
          }}
          className={`${styles.button} ${color === "#FFFFFF" ? styles["button-white"] : ""}`}
          aria-label={`Color ${color}`}
          onClick={() => {
            onColorSelect(hexRGBtoNumber(color));
          }}
        />
      ))}
    </div>
  );
};

export default SimpleColorPicker;
