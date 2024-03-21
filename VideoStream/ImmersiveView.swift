//
//  ImmersiveView.swift
//  VideoStream
//
//  Created by Nandini Thakur on 3/20/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @EnvironmentObject var imageData: ImageData
    
    var body: some View {
//        var skyBoxEntity: Entity? = nil
//        var sphereEntity: Entity? = nil
//        var texture: TextureResource? = nil
        RealityView { content in
            if let scene = try? await Entity(named:"Immersive", in: realityKitContentBundle) {
                content.add(scene)
            }
            let skyBox = createSkyBox()!
            content.add(skyBox)
            
            
        } update: { updateContent in
//            print(imageData.image?.size)
            let imageLeft = imageData.left!
            let imageRight = imageData.right!
            
            let skyBoxEntity = updateContent.entities[1]
            let sphereEntity = updateContent.entities[0].findEntity(named: "Sphere")
            var stereo_material = sphereEntity?.components[ModelComponent.self]?.materials[0] as! ShaderGraphMaterial
            do{
                let textureLeft =  try TextureResource.generate(from: imageLeft.cgImage!, options: TextureResource.CreateOptions.init(semantic: nil))
                let textureRight =  try TextureResource.generate(from: imageRight.cgImage!, options: TextureResource.CreateOptions.init(semantic: nil))
//                try stereo_material.setParameter(name: "left", value: .textureResource(textureLeft))
                try stereo_material.setParameter(name: "right", value: .textureResource(textureRight))
            } catch {
                print("error loading texture \(error)")
            }
            skyBoxEntity.components[ModelComponent.self]?.materials = [stereo_material]
        }
        .onAppear {
            VideoStreamServer.shared.start { newImage in
                DispatchQueue.main.async {
                    imageData.left = newImage.left
                    imageData.right = newImage.right
                }
            }
        }
    }
}

private func createSkyBox() -> Entity? {
    let skyBoxEntity = Entity()
    let largePlane = MeshResource.generatePlane(width: 12.88, height: 7.96)
    var skyBoxMaterial = UnlitMaterial()
    do{
        let texture =  try TextureResource.load(named:"LoadingImage")
        skyBoxMaterial.color = .init(texture: .init(texture))
    } catch {
        print("error loading texture")
    }
    skyBoxEntity.components.set(
        ModelComponent(mesh: largePlane, materials: [skyBoxMaterial])
    )
    skyBoxEntity.setPosition(SIMD3<Float>(x:0, y:1.5, z:-5), relativeTo: nil)
    return skyBoxEntity
}

//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}
