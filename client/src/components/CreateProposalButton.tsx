import { useCallback, useMemo, useState } from "react";
import { Dialog, DialogTrigger, DialogContent, DialogTitle, DialogClose } from "@/components/ui/Dialog";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/Select";
import { ProposalType } from "@/types";
import { useDojo } from "@/hooks/useDojo";
import { DEFAULT_GAME_ID } from "@/constants";
import { usePaletteColors } from "@/hooks/usePalleteColors";
import { cn, formatColorToRGB, hexRGBtoNumber, rgbaToHex } from "@/utils";

export const CreateProposalButton = ({ className }: { className?: string }) => {
  const [open, setOpen] = useState(false);
  const [proposalType, setProposalType] = useState<ProposalType>();
  const [color, setColor] = useState("#FFFFFF");
  const {
    setup: {
      systemCalls: { createProposal },
      account: { account },
      connectedAccount,
    },
  } = useDojo();
  const paletteColors = usePaletteColors();
  const activeAccount = useMemo(() => connectedAccount || account, [connectedAccount, account]);

  const handleSubmit = useCallback(async () => {
    if (!proposalType) return;

    createProposal(
      activeAccount,
      DEFAULT_GAME_ID,
      proposalType,
      hexRGBtoNumber(formatColorToRGB(color).replace("#", ""))
    );
    setOpen(false);
  }, [proposalType, color, activeAccount, createProposal]);

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button className={cn("mx-auto p-6 text-lg font-semibold", className)}>
          <span className="text-xs md:text-sm">Create A New Proposal</span>
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogTitle>Create A New Proposal</DialogTitle>
        <div className="space-y-4">
          <Select onValueChange={(value) => setProposalType(Number(value))}>
            <SelectTrigger>
              <SelectValue placeholder="Select Proposal Type" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="1">Add Color</SelectItem>
              <SelectItem value="2">Reset To White</SelectItem>
            </SelectContent>
          </Select>
          {proposalType === ProposalType.AddNewColor && (
            <div className="space-y-2">
              <label htmlFor="color" className="block text-sm font-medium">
                Choose a color to add to the canvas
              </label>
              <Input
                id="color"
                type="color"
                value={color}
                onChange={(e) => setColor(e.target.value)}
                placeholder="#FFFFFF"
                className="cursor-pointer size-10 p-0"
              />
            </div>
          )}
          {proposalType === ProposalType.ResetToWhiteByColor && (
            <div className="space-y-2">
              <label htmlFor="reset-color" className="block text-sm font-medium">
                Choose a color to turn white on the canvas
              </label>
              <Select onValueChange={(value) => setColor(value)}>
                <SelectTrigger>
                  <SelectValue placeholder="Select Proposal Type" />
                </SelectTrigger>
                <SelectContent>
                  {paletteColors.map((color, index) => (
                    <SelectItem key={index} value={rgbaToHex(color)}>
                      <div className="flex items-center space-x-4">
                        <div className="w-4 h-4 rounded-full" style={{ backgroundColor: rgbaToHex(color) }} />
                        <p>{rgbaToHex(color)}</p>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}
          <div className="flex justify-end space-x-2">
            <DialogClose asChild>
              <Button variant="outline">Back</Button>
            </DialogClose>
            <Button onClick={handleSubmit}>Submit</Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};
