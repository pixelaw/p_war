import { usePixelawProvider } from "@pixelaw/react";
import { StarknetWalletSelectorPage } from "@pixelaw/react-dojo";

export interface WalletPickerProps {
  onClose: () => void;
}

export const WalletPicker: React.FC<WalletPickerProps> = ({ onClose: _ }) => {
  const { engine } = usePixelawProvider();

  if (engine!.id === "dojo") {
    return (
      <div className={"pickerPanel"}>
        <StarknetWalletSelectorPage />
      </div>
    );
  }
  return (
    <div>
      <p>not implemented</p>
    </div>
  );
};
