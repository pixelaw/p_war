import { PixelViewer } from "@/components/PixelViewer";
import { Header } from "@/components/Header";
import { ProposalList } from "@/components/ProposalList";

export const App = () => {
  return (
    <>
      <Header />
      <ProposalList />
      <PixelViewer />
    </>
  );
};
