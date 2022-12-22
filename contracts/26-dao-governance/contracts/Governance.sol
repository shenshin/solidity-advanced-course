// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Governance {
    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
    }

    struct Proposal {
        uint256 votingStarts;
        uint256 votingEnds;
        bool executed;
    }

    // what states proposal may have
    // pending - voting has not started yet
    // active - currently going
    // succeeded - finished, proposal is accepted
    // defeated - finished, proposal is declined
    // executed - proposal is implemented
    enum ProposalState {
        Pending,
        Active,
        Succeeded,
        Defeated,
        Executed
    }

    mapping(bytes32 => Proposal) public proposals;
    mapping(bytes32 => ProposalVote) public proposalVotes;

    uint256 public constant VOTING_DELAY = 10; // seconds
    // in real life should last several days
    uint256 public constant VOTING_DURATION = 60;

    event ProposalAdded(bytes32 proposalId);

    IERC20 public token;

    constructor(IERC20 _token) {
        token = _token;
    }

    // creates a unique prposal identifier
    function generateProposalId(
        address _to,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        bytes32 _descriptionHash
    ) internal pure returns (bytes32) {
        return
            keccak256(abi.encode(_to, _value, _func, _data, _descriptionHash));
    }

    function propose(
        // who to pay
        address _to,
        // how much to pay
        uint256 _value,
        // function we want to call
        string calldata _func,
        // function data
        bytes calldata _data,
        string calldata _description
    ) external returns (bytes32) {
        // only the one who owns tokens can create proposals
        require(token.balanceOf(msg.sender) > 0, 'not enough tokens');

        bytes32 proposalId = generateProposalId(
            _to,
            _value,
            _func,
            _data,
            // not to pass the long string to the function
            keccak256(bytes(_description))
        );
        // make sure we don't have running proposal with the same ID
        require(
            proposals[proposalId].votingStarts == 0,
            'proposal already exists'
        );

        // create new proposal
        proposals[proposalId] = Proposal({
            votingStarts: block.timestamp + VOTING_DELAY,
            votingEnds: block.timestamp + VOTING_DELAY + VOTING_DURATION,
            executed: false
        });

        emit ProposalAdded(proposalId);

        return proposalId;
    }

    function execute(
        address _to,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        bytes32 _descriptionHash
    ) external returns (bytes memory) {
        bytes32 proposalId = generateProposalId(
            _to,
            _value,
            _func,
            _data,
            _descriptionHash
        );
        // make sure the proposal was approved
        require(state(proposalId) == ProposalState.Succeeded, 'invalid state');

        Proposal storage proposal = proposals[proposalId];

        proposal.executed = true;

        bytes memory data;
        // if there exists the function name then we encode a
        // function call
        if (bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
            // if there's no function name, just call the _data param
        } else {
            data = _data;
        }

        (bool success, bytes memory resp) = _to.call{value: _value}(data);
        require(success, 'tx failed');

        return resp;
    }

    function vote(bytes32 proposalId, uint8 voteType) external {
        require(state(proposalId) == ProposalState.Active, 'invalid state');

        // this is a very simple realization
        // in real life it should recorded
        // how many tokens the participant had at the beginning of the voting
        // to prevent from voting multiple times using the same tokens
        uint256 votingPower = token.balanceOf(msg.sender);
        // only token holders can vote
        require(votingPower > 0, 'not enough tokens');
        // find recorded proposal by Id
        ProposalVote storage proposalVote = proposalVotes[proposalId];
        // check if the participant has already voted
        require(!proposalVote.hasVoted[msg.sender], 'already voted');

        if (voteType == 0) {
            // add as many votes as the voting power (token balance) is
            proposalVote.againstVotes += votingPower;
        } else if (voteType == 1) {
            proposalVote.forVotes += votingPower;
        } else {
            proposalVote.abstainVotes += votingPower;
        }

        proposalVote.hasVoted[msg.sender] = true;
    }

    function state(bytes32 proposalId) public view returns (ProposalState) {
        Proposal storage proposal = proposals[proposalId];
        ProposalVote storage proposalVote = proposalVotes[proposalId];
        // make sure the voting for the proposal has started
        require(proposal.votingStarts > 0, 'proposal doesnt exist');
        // voting has finished and executed
        if (proposal.executed) {
            return ProposalState.Executed;
        }
        // voting has not started yet
        if (block.timestamp < proposal.votingStarts) {
            return ProposalState.Pending;
        }
        // if it has started but not finished - going at the moment
        if (
            block.timestamp >= proposal.votingStarts &&
            proposal.votingEnds > block.timestamp
        ) {
            return ProposalState.Active;
        }
        // voting has finished and the decision is made
        // quorum mechanism could also be added here
        // e.g. % from the whole voters
        if (proposalVote.forVotes > proposalVote.againstVotes) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }

    receive() external payable {}
}
