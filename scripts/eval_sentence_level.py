import argparse

error_types = [
    "monolingual-typo",
    "monolingual-grammar",
    "monolingual-fluency",
    "bilingual",
    "preferential",
]

def eval_sentence_level(orig, hyp, ref, labels):
    origf = open(orig)
    hypf = open(hyp)
    reff = open(ref)
    labelsf = open(labels)

    # For edited segments:
    # correct edit: hyp sentence matches true sent
    # incorrect edit: hyp sentence makes a diff edit from true
    # no edit: hyp sentence doesn't edit at all
    error_counts = {k: {"correct-edit": 0, "incorrect-edit": 0, "no-edit": 0} for k in error_types + ["unedited-example"]}
    total_correct = 0
    total_num = 0
    num_unedited_examples = 0
    for orig_line, hyp_line, ref_line, labels_line in zip(origf, hypf, reff, labelsf):
        total_num += 1

        if len(labels_line.strip()) == 0:
            num_unedited_examples += 1
            types = ["unedited-example"]
        else:
            types = labels_line.strip().split(",")

        # True pos
        if hyp_line == ref_line:
            total_correct += 1
            for t in types:
                error_counts[t]["correct-edit"] += 1
        # False pos
        elif hyp_line != ref_line and hyp_line != orig_line:
            for t in types:
                error_counts[t]["incorrect-edit"] += 1
        # False neg
        elif hyp_line != ref_line and hyp_line == orig_line:
            for t in types:
                error_counts[t]["no-edit"] += 1
        else:
            assert False, "unknown error type"

    print("Num unedited examples: ", num_unedited_examples)
    print("Error counts", error_counts)
    print("Total correct: ", total_correct)
    print("Total num: ", total_num)
    error_counts["All"] = total_correct / total_num
    return error_counts

def print_sentence_level_acc(error_counts):
    print("{:=^66}".format(" Sentence-level statistics "))
    print("Category".ljust(48), "Acc".ljust(8))

    for cat, cnts in sorted(error_counts.items()):
        if cat == "All": 
            accuracy = cnts 
            print(f"{cat}".ljust(48), str(accuracy).ljust(8))
        else:
            accuracy = cnts["correct-edit"] / (cnts["correct-edit"] + cnts["incorrect-edit"] + cnts["no-edit"])
            print(
                f"{cat} (total num {sum(cnts.values())})".ljust(48),
                str(accuracy).ljust(8)
            )
    print("="*66)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-orig", help="Confirmed target file", required=True)
    parser.add_argument("-hyp", help="A hypothesis file", required=True)
    parser.add_argument("-ref", help="A reference file", required=True)
    parser.add_argument("-sent_labels", help="Sentence-level error type labels", required=True)
    args = parser.parse_args()

    error_counts = eval_sentence_level(args.orig, args.hyp, args.ref, args.sent_labels)
    print_sentence_level_acc(error_counts)
