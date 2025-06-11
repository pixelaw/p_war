import CustomButton from "@/components/CustomButton/CustomButton.tsx";
import type React from "react";

export interface AppPickerButtonProps {
  onClick: () => void;
  onSecondary: () => void;
  appEmoji: string;
  selected: boolean;
}

const AppPickerButton: React.FC<AppPickerButtonProps> = ({
  onClick,
  appEmoji,
  onSecondary,
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
        }}
      >
        ⭐
      </span>
      <span
        style={{
          fontSize: "2rem",
          fontFamily: "'Noto Color Emoji', sans-serif",
          transform: "translate(0, 4px)",
          touchAction: "none",
          userSelect: "none",
        }}
      >
        {appEmoji}
      </span>
    </CustomButton>
  );
};

export default AppPickerButton;
