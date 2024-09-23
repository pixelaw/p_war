import { cn } from "@/utils";
import { DEFAULT_GAME_ID, HEADER_HEIGHT } from "@/constants";
import { Filter, PanelLeftClose, PanelLeftOpen } from "lucide-react";
import { useMemo, useState } from "react";
import { CreateProposalButton } from "@/components/CreateProposalButton";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/Popover";
import { FilterMenu } from "@/components/FilterMenu";
import { useProposals } from "@/hooks/useProposal";
import { ProposalItem } from "./item";

export const ProposalList = () => {
  // Hooks
  const { proposals } = useProposals(DEFAULT_GAME_ID);

  // States
  const [isOpen, setIsOpen] = useState(false);
  const [statusFilter, setStatusFilter] = useState<"All" | "Active" | "Closed">("All");
  const filteredProposals = useMemo(() => {
    return proposals.filter((proposal) => {
      if (statusFilter === "Active") {
        return proposal.is_activated === true;
      } else if (statusFilter === "Closed") {
        return proposal.is_activated === false;
      }
      return true;
    });
  }, [proposals, statusFilter]);

  return (
    <section
      className={cn(
        "z-10 fixed",
        `top-[${HEADER_HEIGHT + 10}px]`,
        isOpen
          ? "rounded-md inset-x-4 md:left-4 md:right-auto bottom-4 overflow-y-auto"
          : "rounded-full active:bg-slate-400 hover:bg-slate-400 left-4 cursor-pointer",
      )}
      onClick={isOpen ? undefined : () => setIsOpen(true)}
    >
      <div className={cn("bg-slate-500 p-3 md:p-4", isOpen || "rounded-full")}>
        <div className={cn("flex flex-col gap-y-4", isOpen ? "flex" : "hidden")}>
          <div className="flex gap-x-2 justify-between">
            <div className="flex items-center space-x-3">
              <p>Proposal List</p>
              <Popover>
                <PopoverTrigger>
                  <Filter size={20} />
                </PopoverTrigger>
                <PopoverContent className="absolute z-10 mt-2 w-48 rounded-md bg-gray-800 shadow-lg">
                  <FilterMenu statusFilter={statusFilter} setStatusFilter={setStatusFilter} />
                </PopoverContent>
              </Popover>
            </div>
            <PanelLeftClose onClick={() => setIsOpen((prev) => !prev)} className="cursor-pointer" />
          </div>

          {/* Scrollable Proposal List */}
          <div className="overflow-y-auto flex flex-col gap-y-4 flex-1 py-2 md:min-w-[450px]">
            {filteredProposals.map((proposal) => (
              <ProposalItem proposal={proposal} key={proposal.index} />
            ))}
            <CreateProposalButton className="w-full" />
          </div>
        </div>

        {/* Button */}
        <PanelLeftOpen
          onClick={() => setIsOpen((prev) => !prev)}
          className={cn(isOpen ? "hidden" : "flex size-full")}
        />
      </div>
    </section>
  );
};
