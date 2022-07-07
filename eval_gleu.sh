#!/bin/bash
# Evaluates model output with GLEU.
# 
# Example usage:
# sh eval_gleu.sh asics dev /path/to/model_output.tgt 

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

python $project_dir/gleu/compute_gleu \
  -s $project_dir/data/$dataset/$split.pert.tok \
  -r $project_dir/data/$dataset/$split.tgt.tok \
  -o $model_output.tok -n 4 
