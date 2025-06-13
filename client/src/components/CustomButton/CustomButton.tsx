import type React from "react";
import { useRef } from "react";
import styles from "./CustomButton.module.css";

interface CustomButtonProps {
  onClick: () => void;
  onSecondary: () => void;
  children: React.ReactNode;
  className?: string;
  selected: boolean;
}

const CustomButton: React.FC<CustomButtonProps> = ({
  onClick,
  onSecondary,
  children,
  className,
  selected,
}) => {
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  const touchStartTimeRef = useRef<number | null>(null);

  const handleContextMenu = (event: React.MouseEvent) => {
    event.preventDefault();
    onSecondary();
  };

  const handleTouchStart = (_event: React.TouchEvent) => {
    touchStartTimeRef.current = Date.now();
    const longPressDuration = 500;
    timeoutRef.current = setTimeout(onSecondary, longPressDuration);
  };

  const handleTouchEnd = (_event: React.TouchEvent) => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    if (touchStartTimeRef.current !== null) {
      const touchDuration = Date.now() - touchStartTimeRef.current;
      if (touchDuration < 500) {
        // onClick()
      }
    }
  };

  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      onClick();
    }
  };

  return (
    <div
      onClick={onClick}
      onContextMenu={handleContextMenu}
      onTouchStart={handleTouchStart}
      onTouchEnd={handleTouchEnd}
      onTouchCancel={handleTouchEnd}
      onKeyDown={handleKeyDown}
      className={`${className ?? ""} ${styles.customButton} ${selected ? styles.selected : ""}`}
    >
      {children}
    </div>
  );
};

export default CustomButton;
