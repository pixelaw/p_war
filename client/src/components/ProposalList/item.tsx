import { DEFAULT_BOARD_SIZE, DEFAULT_GAME_ID, NEEDED_YES_PX } from "@/constants";
import { useDojo } from "@/hooks/useDojo";
import { Proposal } from "@/libs/dojo/typescript/models.gen";
import { Position, ProposalType } from "@/types";
import {
  felt252ToString,
  formatTimeRemaining,
  formatTimeRemainingForTitle,
  formatWalletAddressWithEmoji,
  uint32ToHex,
} from "@/utils";
import React, { useEffect, useMemo, useState } from "react";

export type StartVoteParam = {
  id: number;
  title: string;
  proposer: string;
  forPoints: number;
  againstPoints: number;
  status: string;
  statusColor: string;
  comments: string;
};

type PropsType = {
  proposal?: Proposal;
  onStartVote?: (proposal: StartVoteParam) => void;
  filter?: "All" | "Active" | "Closed";
  searchTerm?: string;
};

const createProposalTitle = (proposalType: ProposalType, target_args_1: number, target_args_2: number) => {
  switch (proposalType) {
    case ProposalType.AddNewColor:
      return `Adding A New Color: ${uint32ToHex(target_args_1).toUpperCase()}`;
    case ProposalType.ResetToWhiteByColor:
      return `Reset To White: ${uint32ToHex(target_args_1).toUpperCase()}`;
    case ProposalType.ExtendGameEndTime:
      return `Extend Game End Time: ${formatTimeRemainingForTitle(target_args_1)}`;
    case ProposalType.ExpandArea:
      return `Expand Area: x ${target_args_1} y ${target_args_2}`;
    default: {
      console.error("unhandled proposal type: ", proposalType);
      return "";
    }
  }
};

const getStatusColor = (status: string) => {
  if (status.startsWith("ends in")) {
    return "bg-green-500";
  } else if (status === "closed") {
    return "bg-purple-500";
  } else {
    return "bg-gray-500";
  }
};

// doesn't work correctly...
const getTextColor = (proposalStatus: string, proposal: Proposal) => {
  if (proposalStatus === "closed" && proposal.yes_px > proposal.no_px) {
    return "text-green-300";
  } else if (proposalStatus === "closed" && proposal.yes_px <= proposal.no_px) {
    return "text-red-300";
  } else {
    return "text-white";
  }
};

export const ProposalItem: React.FC<PropsType> = ({ proposal, onStartVote, filter, searchTerm }) => {
  const {
    setup: {
      systemCalls: { activateProposal },
    },
    account: { account },
    connectedAccount,
  } = useDojo();
  const activeAccount = useMemo(() => connectedAccount || account, [connectedAccount, account]);
  const [proposalStatus, setProposalStatus] = useState("");

  const start = Number(proposal?.start ?? 0);
  const end = Number(proposal?.end ?? 0);

  useEffect(() => {
    if (proposalStatus === "closed") return;

    // Function to update the seconds state every second
    const interval = setInterval(() => {
      const current = Math.floor(Date.now() / 1_000);

      if (current < start) {
        setProposalStatus(`starts in ${formatTimeRemaining(start - current)}`);
      } else if (current > start && current < end) {
        setProposalStatus(`ends in ${formatTimeRemaining(end - current)}`);
      } else {
        setProposalStatus("closed");
      }
    }, 1000);

    // Cleanup function to clear the interval when the component unmounts or when dependencies change
    return () => clearInterval(interval);
  }, [start, end, proposalStatus]); // Empty dependency array ensures this effect runs only once

  if (!proposal) return <></>;

  const hexColor = uint32ToHex(proposal.target_args_1);
  const title = createProposalTitle(proposal.proposal_type, proposal.target_args_1, proposal.target_args_2);
  const canActivateProposal = proposal.yes_px >= NEEDED_YES_PX && proposal.yes_px > proposal.no_px;

  if (
    (filter === "Closed" && proposalStatus !== "closed") ||
    (filter === "Active" && !proposalStatus.includes("ends in")) ||
    (!!searchTerm?.trim() && !title.toLowerCase().includes(searchTerm?.toLowerCase()))
  )
    return <></>;

  const onStartVoteParam = {
    id: proposal.index,
    title,
    proposer: felt252ToString(proposal.author),
    forPoints: proposal.yes_px,
    againstPoints: proposal.no_px,
    status: proposalStatus,
    statusColor: getStatusColor(proposalStatus),
    comments: "",
  };

  const handleActivateProposal = async () => {
    // NOTE: On the assumption that the all existing pixels are belongs to the a game
    const allPixelsInBoard: Position[] = Array.from({ length: DEFAULT_BOARD_SIZE }, (_, x) =>
      Array.from({ length: DEFAULT_BOARD_SIZE }, (_, y) => ({ x, y }))
    ).flat();
    await activateProposal(activeAccount, DEFAULT_GAME_ID, proposal.index, allPixelsInBoard);
  };

  const containerClassName = `relative p-4 rounded-md border transition-colors duration-300 ${
    proposalStatus === "closed" ? "bg-gray-600 border-gray-700" : "bg-gray-800 border-gray-700 hover:border-gray-600"
  }`;
  const isButtonDisabled =
    proposalStatus === "" ||
    proposalStatus.includes("starts") ||
    (!canActivateProposal && proposalStatus === "closed") ||
    proposal.is_activated;

  return (
    <div className={containerClassName}>
      <div className="block">
        <div className="mb-1 flex items-center justify-between">
          <div className={`flex items-center text-sm font-bold ${getTextColor(proposalStatus, proposal)}`}>
            {title}
            {hexColor && <div className="ml-2 size-6 rounded-md" style={{ backgroundColor: hexColor }} />}
          </div>
          <div
            className={`rounded-md px-2 py-1 text-xs text-white ${getStatusColor(proposalStatus)}`}
            style={{ marginLeft: "1rem" }}
          >
            {proposalStatus}
          </div>
        </div>
        <div className="mb-2 text-xs text-gray-400">
          proposed by {formatWalletAddressWithEmoji(proposal.author.toString())}
        </div>
        <div className="mr-30 relative mb-1 flex h-2 rounded-full bg-gray-700" style={{ marginRight: "7rem" }}>
          <div
            className="h-full rounded-l-full bg-green-500"
            style={{
              width: `${(proposal.yes_px / (proposal.yes_px + proposal.no_px)) * 100}%`,
            }}
          />
          <div
            className="h-full rounded-r-full bg-red-500"
            style={{
              width: `${(proposal.no_px / (proposal.yes_px + proposal.no_px)) * 100}%`,
            }}
          />
        </div>
        <div className="mr-30 flex justify-between text-xs text-gray-300" style={{ marginRight: "7rem" }}>
          <div>For {proposal.yes_px} points</div>
          <div>Against {proposal.no_px} points</div>
        </div>
      </div>
      <button
        className={`absolute bottom-4 right-4 rounded-md px-4 py-2 text-sm transition duration-300 ${
          isButtonDisabled
            ? `${getTextColor(proposalStatus, proposal)} cursor-not-allowed bg-gray-500`
            : "bg-blue-600 text-white hover:bg-blue-500"
        }`}
        onClick={() =>
          proposalStatus === "closed" ? handleActivateProposal() : onStartVote ? onStartVote(onStartVoteParam) : ""
        }
        disabled={isButtonDisabled}
      >
        {proposalStatus === ""
          ? "..."
          : proposal.is_activated
          ? "Applied"
          : proposalStatus === "closed"
          ? canActivateProposal
            ? "Activate"
            : "Denied"
          : "Vote"}
      </button>
    </div>
  );
};
