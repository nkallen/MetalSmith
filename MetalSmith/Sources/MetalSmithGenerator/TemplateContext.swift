import Foundation
import MetalKit

@objcMembers public final class TemplateContext: NSObject {
    public let functions: Functions
    public let argument: [String: NSObject]

    public var function: [String: Function] {
        return functions.functionsByName
    }

    public init(functions: Functions, arguments: [String: NSObject]) {
        self.functions = functions
        self.argument = arguments
    }

    public var stencilContext: [String: Any] {
        return [
            "functions": functions,
            "function": functions.functionsByName,
            "argument": argument
        ]
    }
}

@objcMembers public final class Functions: NSObject {

    public let functions: [Function]

    public init(functions: [Function]) {
        self.functions = functions
    }

    public lazy internal(set) var functionsByName: [String: Function] = {
        var functionsByName = [String: Function]()
        self.functions.forEach { functionsByName[$0.name] = $0 }
        return functionsByName
    }()

    public lazy internal(set) var all: [Function] = {
        return self.functions
    }()

    public lazy internal(set) var vertexes: [Function] = {
        return self.functions.filter { $0.functionType == "vertex" }
    }()

    public lazy internal(set) var fragments: [Function] = {
        return self.functions.filter { $0.functionType == "fragment" }
    }()

    public lazy internal(set) var kernels: [Function] = {
        return self.functions.filter { $0.functionType == "kernel" }
    }()
}

@objcMembers public final class Function: NSObject {
    public var name: String
    public var functionType: String
    public var constants: [FunctionConstant]
    public var vertexAttributes: [Attribute]?
    public var stageInputAttributes: [Attribute]?
    public var arguments: [Argument]

    convenience init(_ function: MTLFunction, constants: [MTLFunctionConstant]) throws {
        let functionType: String
        let arguments: [Argument]
        switch function.functionType {
        case .fragment:
            functionType = "fragment"
            //            let descriptor = MTLRenderPipelineDescriptor()
            //            descriptor.fragmentFunction = function
            //            var reflection: MTLRenderPipelineReflection?
            // FIXME not yet supported; need a dummy vertex function
            //            _ = try function.device.makeRenderPipelineState(descriptor: descriptor, options: [.argumentInfo, .bufferTypeInfo], reflection: &reflection)
            //            arguments = reflection!.fragmentArguments!.map { Argument($0) }
            arguments = []
        case .vertex:
            functionType = "vertex"
            //            let descriptor = MTLRenderPipelineDescriptor()
            //            descriptor.vertexFunction = function
            //            var reflection: MTLRenderPipelineReflection?
            //            _ = try function.device.makeRenderPipelineState(descriptor: descriptor, options: [.argumentInfo, .bufferTypeInfo], reflection: &reflection)
            //            arguments = reflection!.vertexArguments!.map { Argument($0) }
            arguments = []
        case .kernel:
            functionType = "kernel"
            var reflection: MTLComputePipelineReflection?
            _ = try function.device.makeComputePipelineState(function: function, options: [.argumentInfo, .bufferTypeInfo], reflection: &reflection)
            arguments = reflection!.arguments.map(Argument.init)
        @unknown default:
            fatalError()
        }

        let stageInputAttributes = function.stageInputAttributes?.map(Attribute.init)
        let vertexAttributes = function.vertexAttributes?.map(Attribute.make)

        self.init(name: function.name, functionType: functionType, constants: constants.map(FunctionConstant.init), stageInputAttributes: stageInputAttributes, vertexAttributes: vertexAttributes, arguments: arguments)
    }

    init(name: String, functionType: String, constants: [FunctionConstant], stageInputAttributes: [Attribute]?, vertexAttributes: [Attribute]?, arguments: [Argument]) {
        self.name = name
        self.functionType = functionType
        self.constants = constants
        self.stageInputAttributes = stageInputAttributes
        self.vertexAttributes = vertexAttributes
        self.arguments = arguments
    }
}

@objcMembers public final class FunctionConstant: NSObject {
    var name: String
    var type: DataType
    var index: Int
    var required: Bool

    convenience init(_ constant: MTLFunctionConstant) {
        self.init(
            name: constant.name,
            type: DataType(of: constant.type),
            index: constant.index,
            required: constant.required)
    }

    init(name: String, type: DataType, index: Int, required: Bool) {
        self.name = name
        self.type = type
        self.index = index
        self.required = required
    }
}

@objcMembers public final class Attribute: NSObject {
    var name: String
    var attributeIndex: Int
    var attributeType: DataType
    var isActive: Bool
    var isPatchControlPointData: Bool
    var isPatchData: Bool

    convenience init(_ attribute: MTLAttribute) {
        self.init(
            name: attribute.name,
            attributeIndex: attribute.attributeIndex,
            attributeType: DataType(of: attribute.attributeType),
            isActive: attribute.isActive,
            isPatchControlPointData: attribute.isPatchControlPointData,
            isPatchData: attribute.isPatchData)
    }

    static func make(_ attribute: MTLVertexAttribute) -> Attribute {
        return Attribute(
            name: attribute.name,
            attributeIndex: attribute.attributeIndex,
            attributeType: DataType(of: attribute.attributeType),
            isActive: attribute.isActive,
            isPatchControlPointData: attribute.isPatchControlPointData,
            isPatchData: attribute.isPatchData)
    }

    init(name: String, attributeIndex: Int, attributeType: DataType, isActive: Bool, isPatchControlPointData: Bool, isPatchData: Bool) {
        self.name = name
        self.attributeIndex = attributeIndex
        self.attributeType = attributeType
        self.isActive = isActive
        self.isPatchControlPointData = isPatchControlPointData
        self.isPatchData = isPatchData
    }
}

@objcMembers public final class Argument: NSObject {
    var name: String
    var isActive: Bool
    var index: Int
    var type: String
    var access: String
    var bufferAlignment: Int?
    var bufferDataSize: Int?
    var bufferDataType: DataType?
    var bufferStructType: StructType?
    var bufferPointerType: PointerType?
    var textureDataType: DataType?
    var textureType: String?
    var isDepthTexture: Bool?
    var arrayLength: Int
    var threadgroupMemoryAlignment: Int?
    var threadgroupMemoryDataSize: Int?

    convenience init(_ argument: MTLArgument) {
        var textureDataType: DataType? = nil
        var textureType: String? = nil
        var isDepthTexture: Bool? = nil
        var threadgroupMemoryAlignment: Int? = nil
        var threadgroupMemoryDataSize: Int? = nil
        var bufferAlignment: Int? = nil
        var bufferDataSize: Int? = nil
        var bufferDataType: DataType? = nil
        var bufferStructType: StructType? = nil
        var bufferPointerType: PointerType? = nil


        switch argument.type {
        case .texture:
            textureDataType = DataType(of: argument.textureDataType)
            textureType = String(describing: argument.textureType)
            isDepthTexture = argument.isDepthTexture
        case .buffer:
            bufferAlignment = argument.bufferAlignment
            bufferDataSize = argument.bufferDataSize
            bufferDataType = DataType(of: argument.bufferDataType)
            if argument.bufferDataType == .struct {
                bufferStructType = argument.bufferStructType.map(StructType.init)
            } else if argument.bufferDataType == .pointer {
                bufferPointerType = argument.bufferPointerType.map(PointerType.init)
            }
        case .sampler: ()
        case .threadgroupMemory:
            threadgroupMemoryAlignment = argument.threadgroupMemoryAlignment
            threadgroupMemoryDataSize = argument.threadgroupMemoryDataSize
        @unknown default: ()
        }

        self.init(
            name: argument.name,
            isActive: argument.isActive,
            index: argument.index,
            type: String(describing: argument.type),
            access: String(describing: argument.access),
            bufferAlignment: bufferAlignment,
            bufferDataSize: bufferDataSize,
            bufferDataType: bufferDataType,
            bufferStructType: bufferStructType,
            bufferPointerType: bufferPointerType,
            textureDataType: textureDataType,
            textureType: textureType,
            isDepthTexture: isDepthTexture,
            arrayLength: argument.arrayLength,
            threadgroupMemoryAlignment: threadgroupMemoryAlignment,
            threadgroupMemoryDataSize: threadgroupMemoryDataSize)
    }

    init(name: String, isActive: Bool, index: Int, type: String, access: String, bufferAlignment: Int?, bufferDataSize: Int?, bufferDataType: DataType?, bufferStructType: StructType?, bufferPointerType: PointerType?, textureDataType: DataType?, textureType: String?, isDepthTexture: Bool?, arrayLength: Int, threadgroupMemoryAlignment: Int?, threadgroupMemoryDataSize: Int?) {
        self.name = name
        self.isActive = isActive
        self.index = index
        self.type = type
        self.access = access
        self.bufferAlignment = bufferAlignment
        self.bufferDataSize = bufferDataSize
        self.bufferDataType = bufferDataType
        self.bufferStructType = bufferStructType
        self.bufferPointerType = bufferPointerType
        self.textureDataType = textureDataType
        self.textureType = textureType
        self.isDepthTexture = isDepthTexture
        self.arrayLength = arrayLength
        self.threadgroupMemoryAlignment = threadgroupMemoryAlignment
        self.threadgroupMemoryDataSize = threadgroupMemoryDataSize
    }
}

@objcMembers public final class StructType: NSObject {
    var members: [StructMember]

    convenience init(_ structType: MTLStructType) {
        self.init(members: structType.members.map(StructMember.init))
    }

    init(members: [StructMember]) {
        self.members = members
    }
}

@objcMembers public final class StructMember: NSObject {
    var name: String
    var dataType: DataType
    var offset: Int
    var argumentIndex: Int
    var arrayType: ArrayType?
    var structType: StructType?
    var pointerType: PointerType?
    var textureReferenceType: TextureReferenceType?

    convenience init(_ member: MTLStructMember) {
        self.init(name: member.name, dataType: DataType(of: member.dataType), offset: member.offset, argumentIndex: member.argumentIndex, arrayType: member.arrayType().map(ArrayType.init), structType: member.structType().map(StructType.init), pointerType: member.pointerType().map(PointerType.init), textureReferenceType: member.textureReferenceType().map(TextureReferenceType.init))
    }

    init(name: String, dataType: DataType, offset: Int, argumentIndex: Int, arrayType: ArrayType?, structType: StructType?, pointerType: PointerType?, textureReferenceType: TextureReferenceType?) {
        self.name = name
        self.dataType = dataType
        self.offset = offset
        self.argumentIndex = argumentIndex
        self.arrayType = arrayType
        self.structType = structType
        self.pointerType = pointerType
        self.textureReferenceType = textureReferenceType
    }
}

@objcMembers public final class TextureReferenceType: NSObject {
    var textureType: String
    var textureDataType: DataType
    var access: String
    var isDepthTexture: Bool

    convenience init(_ tex: MTLTextureReferenceType) {
        self.init(textureType: String(describing: tex.textureType), textureDataType: DataType(of: tex.textureDataType), access: String(describing: tex.access), isDepthTexture: tex.isDepthTexture)
    }

    init(textureType: String, textureDataType: DataType, access: String, isDepthTexture: Bool) {
        self.textureType = textureType
        self.textureDataType = textureDataType
        self.access = access
        self.isDepthTexture = isDepthTexture
    }
}

@objcMembers public final class PointerType: NSObject {
    var alignment: Int
    var dataSize: Int
    var elementType: DataType
    var access: String
    var elementIsArgumentBuffer: Bool
    var elementArrayType: ArrayType?
    var elementStructType: StructType?

    convenience init(_ type: MTLPointerType) {
        self.init(alignment: type.alignment, dataSize: type.dataSize, elementType: DataType(of: type.elementType), access: String(describing: type.access), elementIsArgumentBuffer: type.elementIsArgumentBuffer, elementArrayType: type.elementArrayType().map(ArrayType.init), elementStructType: type.elementStructType().map(StructType.init))
    }

    init(alignment: Int, dataSize: Int, elementType: DataType, access: String, elementIsArgumentBuffer: Bool, elementArrayType: ArrayType?, elementStructType: StructType?) {
        self.alignment = alignment
        self.dataSize = dataSize
        self.elementType = elementType
        self.access = access
        self.elementIsArgumentBuffer = elementIsArgumentBuffer
        self.elementArrayType = elementArrayType
        self.elementStructType = elementStructType
    }
}

@objcMembers public final class ArrayType: NSObject {
    var arrayLength: Int
    var elementType: DataType
    var stride: Int
    var argumentIndexStride: Int
    var element: ArrayType?
    var elementStructType: StructType?
    var elementPointerType: PointerType?
    var elementTextureReferenceType: TextureReferenceType?

    convenience init(_ arr: MTLArrayType) {
        self.init(arrayLength: arr.arrayLength, elementType: DataType(of: arr.elementType), stride: arr.stride, argumentIndexStride: arr.argumentIndexStride, element: arr.element().map(ArrayType.init), elementStructType: arr.elementStructType().map(StructType.init), elementPointerType: arr.elementPointerType().map(PointerType.init), elementTextureReferenceType: arr.elementTextureReferenceType().map(TextureReferenceType.init))
    }

    init(arrayLength: Int, elementType: DataType, stride: Int, argumentIndexStride: Int, element: ArrayType?, elementStructType: StructType?, elementPointerType: PointerType?, elementTextureReferenceType: TextureReferenceType?) {
        self.arrayLength = arrayLength
        self.elementType = elementType
        self.stride = stride
        self.argumentIndexStride = argumentIndexStride
        self.element = element
        self.elementStructType = elementStructType
        self.elementPointerType = elementPointerType
        self.elementTextureReferenceType = elementTextureReferenceType
    }
}

extension MTLArgumentType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .buffer:
            return "buffer"
        case .threadgroupMemory:
            return "threadgroupMemory"
        case .texture:
            return "texture"
        case .sampler:
            return "sampler"
            //        case .imageblock:
            //            return "imageblock"
            //        case .imageblockData:
            //            return "imageblockData"
        }
    }
}

@objcMembers public final class DataType: NSObject {
    let metalName: String
    let swiftName: String

    init(of type: MTLDataType) {
        let metalName: String
        let swiftName: String
        switch type {
        case .none:
            metalName = "none"
            swiftName = ""
        case .struct:
            metalName = "struct"
            swiftName = ""
        case .array:
            metalName = "array"
            swiftName = ""
        case .float:
            metalName = "float"
            swiftName = "Float"
        case .float2:
            metalName = "float2"
            swiftName = "simd_float2"
        case .float3:
            metalName = "float3"
            swiftName = "simd_float3"
        case .float4:
            metalName = "float4"
            swiftName = "simd_float4"
        case .float2x2:
            metalName = "float2x2"
            swiftName = "simd_float2x2"
        case .float2x3:
            metalName = "float2x3"
            swiftName = "simd_float2x2"
        case .float2x4:
            metalName = "float2x4"
            swiftName = "simd_float2x4"
        case .float3x2:
            metalName = "float3x2"
            swiftName = "simd_float3x2"
        case .float3x3:
            metalName = "float3x3"
            swiftName = "simd_float3x3"
        case .float3x4:
            metalName = "float3x4"
            swiftName = "simd_float3x4"
        case .float4x2:
            metalName = "float4x2"
            swiftName = "simd_float4x2"
        case .float4x3:
            metalName = "float4x3"
            swiftName = "simd_float4x3"
        case .float4x4:
            metalName = "float4x4"
            swiftName = "simd_float4x4"
        case .half:
            metalName = "half"
            swiftName = "Half"
        case .half2:
            metalName = "half2"
            swiftName = "simd_half2"
        case .half3:
            metalName = "half3"
            swiftName = "simd_half3"
        case .half4:
            metalName = "half4"
            swiftName = "simd_half4"
        case .half2x2:
            metalName = "half2x2"
            swiftName = "simd_half2x2"
        case .half2x3:
            metalName = "half2x3"
            swiftName = "simd_half2x3"
        case .half2x4:
            metalName = "half2x4"
            swiftName = "simd_half2x4"
        case .half3x2:
            metalName = "half3x2"
            swiftName = "simd_half3x2"
        case .half3x3:
            metalName = "half3x3"
            swiftName = "simd_half3x3"
        case .half3x4:
            metalName = "half3x4"
            swiftName = "simd_half3x4"
        case .half4x2:
            metalName = "half4x2"
            swiftName = "simd_half4x2"
        case .half4x3:
            metalName = "half4x3"
            swiftName = "simd_half4x3"
        case .half4x4:
            metalName = "half4x4"
            swiftName = "simd_half4x4"
        case .int:
            metalName = "int"
            swiftName = "Int32"
        case .int2:
            metalName = "int2"
            swiftName = "simd_int2"
        case .int3:
            metalName = "int3"
            swiftName = "simd_int3"
        case .int4:
            metalName = "int4"
            swiftName = "simd_int4"
        case .uint:
            metalName = "uint"
            swiftName = "UInt32"
        case .uint2:
            metalName = "uint2"
            swiftName = "simd_uint2"
        case .uint3:
            metalName = "uint3"
            swiftName = "simd_uint3"
        case .uint4:
            metalName = "uint4"
            swiftName = "simd_uint4"
        case .short:
            metalName = "short"
            swiftName = "Int16"
        case .short2:
            metalName = "short2"
            swiftName = "simd_short2"
        case .short3:
            metalName = "short3"
            swiftName = "simd_short3"
        case .short4:
            metalName = "short4"
            swiftName = "simd_short4"
        case .ushort:
            metalName = "ushort"
            swiftName = "UInt16"
        case .ushort2:
            metalName = "ushort2"
            swiftName = "simd_ushort2"
        case .ushort3:
            metalName = "ushort3"
            swiftName = "simd_ushort3"
        case .ushort4:
            metalName = "ushort4"
            swiftName = "simd_ushort4"
        case .char:
            metalName = "char"
            swiftName = "Int8"
        case .char2:
            metalName = "char2"
            swiftName = "simd_char2"
        case .char3:
            metalName = "char3"
            swiftName = "simd_char3"
        case .char4:
            metalName = "char4"
            swiftName = "simd_char4"
        case .uchar:
            metalName = "uchar"
            swiftName = "UInt8"
        case .uchar2:
            metalName = "uchar2"
            swiftName = "simd_uchar2"
        case .uchar3:
            metalName = "uchar3"
            swiftName = "simd_uchar3"
        case .uchar4:
            metalName = "uchar4"
            swiftName = "simd_uchar4"
        case .bool:
            metalName = "bool"
            swiftName = "Bool"
        case .bool2:
            metalName = "bool2"
            swiftName = "simd_bool2"
        case .bool3:
            metalName = "bool3"
            swiftName = "simd_bool3"
        case .bool4:
            metalName = "bool4"
            swiftName = "simd_bool4"
        case .texture:
            metalName = "texture"
            swiftName = "MTLTexture"
        case .sampler:
            metalName = "sampler"
            swiftName = "MTLSampler"
        case .pointer:
            metalName = "pointer"
            swiftName = ""
        case .renderPipeline:
            metalName = "renderPipeline"
            swiftName = ""
        case .indirectCommandBuffer:
            metalName = "indirectCommandBuffer"
            swiftName = ""
        @unknown default:
            fatalError()
        }
        self.metalName = metalName
        self.swiftName = swiftName
    }
}

extension MTLArgumentAccess: CustomStringConvertible {
    public var description: String {
        switch self {
        case .readOnly:
            return "readOnly"
        case .readWrite:
            return "readWrite"
        case .writeOnly:
            return "writeOnly"
        }
    }
}

extension MTLTextureType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .type1D:
            return "type1D"
        case .type1DArray:
            return "type1DArray"
        case .type2D:
            return "type2D"
        case .type2DArray:
            return "type2DArray"
        case .type2DMultisample:
            return "type2DMultisample"
        case .typeCube:
            return "typeCube"
        case .typeCubeArray:
            return "typeCubeArray"
        case .type3D:
            return "type3D"
        case .type2DMultisampleArray:
            return "type2DMultisampleArray"
        case .typeTextureBuffer:
            return "typeTextureBuffer"
        @unknown default:
            return "unknown"
        }
    }
}
