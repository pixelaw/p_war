import { usePixelawProvider } from "@pixelaw/react";
import { StarknetWalletSelectorPage } from "@pixelaw/react-dojo";

export const WalletSelectorPage = () => {
  const { engine } = usePixelawProvider();

  if (engine!.id === "dojo") {
    return <StarknetWalletSelectorPage />;
  }
  return (
    <div>
      <p>not implemented</p>
    </div>
  );
};
