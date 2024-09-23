import React, { useCallback, useMemo, useState } from "react";
import FilterMenu from "@/components/FilterMenu";
import { Search, Filter } from "lucide-react";
import { DEFAULT_GAME_ID } from "@/constants";
import { useProposals } from "@/hooks/useProposal";
import { ProposalItem, StartVoteParam } from "./item";
import { useDojo } from "@/hooks/useDojo";
import { cn } from "@/utils";

export const ProposalList = () => {
  // Hooks
  const {
    setup: {
      systemCalls: { vote },
      account: { account },
      connectedAccount,
    },
  } = useDojo();
  const proposals = useProposals(DEFAULT_GAME_ID);

  // State
  const [filterOpen, setFilterOpen] = useState(false);
  const [statusFilter, setStatusFilter] = useState<"All" | "Active" | "Closed">("All");
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedProposal, setSelectedProposal] = useState<StartVoteParam | null>(null);
  const [voteType, setVoteType] = useState<"for" | "against">("for");
  const [votePoints, setVotePoints] = useState<number>(0);
  const activeAccount = useMemo(() => connectedAccount || account, [connectedAccount, account]);

  // Handlers
  const handleVote = useCallback(
    (proposal: StartVoteParam) => {
      setSelectedProposal(proposal);
      setVotePoints(0);
    },
    [setSelectedProposal, setVotePoints]
  );

  const handleVoteProposal = useCallback(async () => {
    if (!selectedProposal) return;
    await vote(activeAccount, DEFAULT_GAME_ID, selectedProposal.id, votePoints, voteType === "for");
  }, [activeAccount, selectedProposal, votePoints, voteType, vote]);

  const extractHexColor = (title: string) => {
    const match = title.match(/#[0-9A-Fa-f]{6}/);
    return match ? match[0].toUpperCase() : null;
  };

  const closeModal = () => {
    setSelectedProposal(null);
  };

  const toggleVoteType = () => {
    setVoteType(voteType === "for" ? "against" : "for");
  };

  const handleVotePointsChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setVotePoints(Number(value));
  };

  return (
    <div className="absolute top-32 left-8 z-10 bg-slate-900 p-4">
      <div className={cn("mb-4 flex flex-col space-y-6 items-center justify-between", selectedProposal ? "blur" : "")}>
        <div className="flex items-center justify-between">
          <div className="relative w-full">
            <input
              type="text"
              placeholder="Search"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full rounded-md bg-gray-800 p-2 pl-10 text-white"
            />
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">
              <Search />
            </span>
          </div>
          <div className="relative ml-1 flex items-center">
            <button className="rounded-md bg-gray-700 px-4 py-2 text-white" onClick={() => setFilterOpen(!filterOpen)}>
              <Filter />
            </button>
            {filterOpen && (
              <div className="absolute z-10 mt-2 w-48 rounded-md bg-gray-800 shadow-lg">
                <FilterMenu statusFilter={statusFilter} setStatusFilter={setStatusFilter} />
              </div>
            )}
          </div>
        </div>

        <button className="mx-auto rounded-md bg-blue-600 px-6 py-3 text-lg font-semibold text-white shadow-lg transition duration-300 hover:bg-blue-500">
          Create A New Proposal
        </button>
      </div>
      <div className={cn("overflow-y-auto px-6", selectedProposal ? "blur" : "")}>
        <div className="space-y-4">
          {proposals.map((proposal) => {
            return (
              <ProposalItem
                proposal={proposal}
                key={proposal.index}
                onStartVote={handleVote}
                filter={statusFilter}
                searchTerm={searchTerm}
              />
            );
          })}
        </div>
      </div>
      {selectedProposal && (
        <div className="fixed inset-0 z-20 flex items-center justify-center bg-black/50">
          <div className="w-1/3 rounded-lg bg-gray-800 p-6 text-white shadow-lg">
            <h2 className="mb-4 flex items-center text-xl font-bold">
              {selectedProposal.title}
              {extractHexColor(selectedProposal.title) && (
                <div
                  className="ml-2 size-6 rounded-md"
                  style={{
                    backgroundColor: extractHexColor(selectedProposal.title) || undefined,
                  }}
                />
              )}
            </h2>
            <div className="mb-4 flex items-center justify-between">
              <button
                className={cn("w-full rounded-md p-2", voteType === "for" ? "bg-blue-600" : "bg-gray-600")}
                onClick={toggleVoteType}
              >
                For
              </button>
              <button
                className={cn("ml-4 w-full rounded-md p-2", voteType === "against" ? "bg-blue-600" : "bg-gray-600")}
                onClick={toggleVoteType}
              >
                Against
              </button>
            </div>
            <div className="mb-4">
              <label className="mb-2 block">Voting Power(PX)</label>
              <input
                type="number"
                value={votePoints}
                onChange={handleVotePointsChange}
                className="w-full rounded-md border bg-gray-700 p-2 text-white"
              />
            </div>
            <div className="flex justify-end">
              <button className="mr-2 rounded-md bg-gray-600 px-4 py-2 text-white" onClick={closeModal}>
                Cancel
              </button>
              <button className="rounded-md bg-blue-600 px-4 py-2 text-white" onClick={handleVoteProposal}>
                Submit
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
