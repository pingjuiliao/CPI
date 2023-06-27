#include "llvm/Transforms/Instrumentation/CPI.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

PreservedAnalyses CPIPass::run(Module &M, ModuleAnalysisManager &AM) {
  for (auto &F: M) {
    errs() << F.getName() << "\n";
  }
  return PreservedAnalyses::all();
}
