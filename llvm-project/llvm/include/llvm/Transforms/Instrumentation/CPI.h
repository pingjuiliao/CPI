#ifndef LLVM_TRANSFORMS_INSTRUMENTATION_CPI_H
#define LLVM_TRANSFORMS_INSTRUMENTATION_CPI_H

#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/PassManager.h"

namespace llvm {
class CPIPass: public PassInfoMixin<CPIPass> {
public:
  static bool isRequired() {return true;}
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);
  bool functionInstrumentation(Function &F);
private:
  DenseMap<StringRef, FunctionType*> libCallFuncTyMap;
  bool isSensitiveType(Value*);
  bool insertCPILibraryCall(Instruction*, StringRef, Value*, bool, bool);
  void prepareLibFunctionCalleeType(LLVMContext&);
};

} // end namespace llvm

#endif  // LLVM_TRANSFORMS_INSTRUMENTATION_CPI_H
