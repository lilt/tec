#!/bin/bash
# Evaluates model output with M2. 
# 
# Example usage:
# sh eval_m2.sh asics dev /path/to/model_output.tgt 

if [ "$#" -ne 3 ]; then
    echo "Not enough arguments: dataset, split, model_output required."
    exit 2
fi

# 'asics', 'cricut', or 'digitalocean'
dataset=$1 
# 'dev', 'test'
split=$2
model_output=$3

project_dir=$(dirname "$(realpath $0)")

python3 -m spacy download en

for file in pert tgt; do
  if [ ! -f $project_dir/data/$dataset/$split.$file.tok ]; then
    echo "Generating tokenized file $project_dir/$data/$dataset/$split.$file.tok..."
    cat $project_dir/data/$dataset/$split.$file \
      | $project_dir/mosestokenizer/tokenizer/tokenizer.perl -no-escape -l de \
      > $project_dir/data/$dataset/$split.$file.tok 
  fi
done

if [ ! -f $project_dir/data/$dataset/$split.m2 ]; then
  echo "Generating reference m2..."
  errant_parallel -orig $project_dir/data/$dataset/$split.pert.tok \
    -cor $project_dir/data/$dataset/$split.tgt.tok \
    -out $project_dir/data/$dataset/$split.m2
fi

echo "Tokenizing model output..."
cat $model_output \
  | $project_dir/mosestokenizer/tokenizer/tokenizer.perl -no-escape -l de \
  > $model_output.tok 
echo "Generating hypothesis m2..."
errant_parallel -orig $project_dir/data/$dataset/$split.pert.tok \
  -cor $model_output.tok \
  -out $model_output.m2

errant_compare -hyp $model_output.m2 -ref $project_dir/data/$dataset/$split.m2
