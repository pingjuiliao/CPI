#ifndef LLVM_TRANSFORMS_INSTRUMENTATION_CPI_H
#define LLVM_TRANSFORMS_INSTRUMENTATION_CPI_H

#include "llvm/IR/PassManager.h"

namespace llvm {
class CPIPass: public PassInfoMixin<CPIPass> {
public:
  static bool isRequired() {return true;}
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);
};

} // end namespace llvm

#endif  // LLVM_TRANSFORMS_INSTRUMENTATION_CPI_H
