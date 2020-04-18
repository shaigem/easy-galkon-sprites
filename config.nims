task unpack, "Compile the unpack tool":
  --d:release
  setCommand "c", "tools/unpack"

task pack, "Compile the pack tool":
  --d:release
  setCommand "c", "tools/pack"
