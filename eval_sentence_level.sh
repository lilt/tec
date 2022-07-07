#!/bin/bash
# Evaluates per-category sentence-level accuracy for the ASICS test set (where error labels are included). 
# 
# Example usage:
# sh eval_sentence_level.sh /path/to/model_output.tgt 

if [ "$#" -ne 1 ]; then
    echo "Not enough arguments: model_output required."
    exit 2
fi

dataset=asics
split=test
model_output=$1

project_dir=$(dirname "$(realpath $0)")

for file in pert tgt; do
  if [ ! -f $project_dir/data/$dataset/$split.$file.tok ]; then
    echo "Generating tokenized file $project_dir/$data/$dataset/$split.$file.tok..."
    cat $project_dir/data/$dataset/$split.$file \
      | $project_dir/mosestokenizer/tokenizer/tokenizer.perl -no-escape -l de \
      > $project_dir/data/$dataset/$split.$file.tok 
  fi
done

echo "Tokenizing model output..."
cat $model_output \
  | $project_dir/mosestokenizer/tokenizer/tokenizer.perl -no-escape -l de \
  > $model_output.tok 

python $project_dir/scripts/eval_sentence_level.py \
  -orig $project_dir/data/$dataset/$split.pert.tok \
  -ref $project_dir/data/$dataset/$split.tgt.tok \
  -sent_labels $project_dir/data/$dataset/$split.errorlabels \
  -hyp $model_output.tok
