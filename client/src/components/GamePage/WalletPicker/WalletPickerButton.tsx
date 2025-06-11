import CustomButton from "@/components/CustomButton/CustomButton.tsx";
import type React from "react";

export interface WalletPickerButtonProps {
  onClick: () => void;
  onSecondary: () => void;
  playerEmoji: string;
  selected: boolean;
}

const WalletPickerButton: React.FC<WalletPickerButtonProps> = ({
  onClick,
  onSecondary,
  playerEmoji,
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
        👤
      </span>
      <span
        style={{
          fontSize: "2.2rem",
          fontFamily: "'Noto Color Emoji', sans-serif",
          transform: "translate(0, -0.4rem)",
        }}
      >
        {playerEmoji}
      </span>
    </CustomButton>
  );
};

export default WalletPickerButton;
