#include "llvm/Transforms/Instrumentation/CPI.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

bool CPIPass::isSensitiveType(Value* value) {
  return value->getType()->isPointerTy();
}

bool CPIPass::functionInstrumentation(Function &F) {
  for (Instruction &I: instructions(F)) {
    // insert cpi_ptr_store
    if (auto *STRI = dyn_cast<StoreInst>(&I)) {
      Value* val = STRI->getValueOperand();
      if (isSensitiveType(val)) {
        Value* ptr = STRI->getPointerOperand();
        insertCPILibraryCall(STRI, "cpi_ptr_store", ptr, 
                             /*isPointer=*/true,
                             /*insertAfter=*/true);
      }
    }
    
    // insert cpi_ptr_check 
    if (auto *CI = dyn_cast<CallInst>(&I)) {
      if (CI->isIndirectCall()) {
        Value* ptr;
        Value* CallTarget = CI->getCalledOperand();
        if (auto LDI = dyn_cast<LoadInst>(CallTarget)) {
          ptr = LDI->getPointerOperand();
        } else {
          errs() << "[ERROR] unhandled instruction\n";
          continue;
        }
        insertCPILibraryCall(CI, "cpi_ptr_check", ptr,
                             /*isPointer=*/true,
                             /*insertAfter=*/false);
      }
    } 
  }  
  return true;
}

bool CPIPass::insertCPILibraryCall(Instruction* I, StringRef fname, 
                          Value* value, bool isPointer, bool insertAfter) {
  Value* ptr;
  errs() << "store inst: " << *I << "\n";
  Module* M = I->getModule();
  LLVMContext& Ctx = M->getContext(); 
  // FunctionType* libCallType = FunctionType::get(Type::getInt32Ty(Ctx), 
   //                                             {Type::getInt8PtrTy(Ctx)});
   //
  // FunctionCallee PutsFunc = M->getOrInsertFunction("puts", libCallType);
  FunctionType* libCallType = libCallFuncTyMap[fname];
  FunctionCallee libFunc = M->getOrInsertFunction(fname, libCallType); 

  IRBuilder<> IRB(I);
  if (insertAfter) {
    IRB.SetInsertPoint(I->getNextNode());
  }
  // Constant* GStr = IRB.CreateGlobalStringPtr(fname);
  
  if (isPointer) {
    ptr = value;
  } else {
    ptr = IRB.CreateInBoundsGEP(IRB.getInt8PtrTy(),
                                value, {IRB.getInt32(0)});
  }

  IRB.CreateCall(libFunc, {ptr});

  return true;
}


// hardcoding the library function type
void CPIPass::prepareLibFunctionCalleeType(LLVMContext& Ctx) {
  libCallFuncTyMap["cpi_ptr_store"] = FunctionType::get(Type::getInt32Ty(Ctx), {Type::getInt8PtrTy(Ctx)});
  libCallFuncTyMap["cpi_ptr_check"] = FunctionType::get(Type::getInt32Ty(Ctx), {Type::getInt8PtrTy(Ctx)});
}


PreservedAnalyses CPIPass::run(Module &M, ModuleAnalysisManager &AM) {

  
  LLVMContext& Ctx = M.getContext();
  prepareLibFunctionCalleeType(Ctx);

  for (auto &F: M) {
    if (F.isDeclaration() || F.isIntrinsic()) {
      errs() << F.getName() << " will not be instrumented\n";
      continue;
    }
    functionInstrumentation(F);
  }
  return PreservedAnalyses::all();
}



