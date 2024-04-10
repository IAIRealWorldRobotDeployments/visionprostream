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
        RealityView { content in
            if let scene = try? await Entity(named:"Immersive", in: realityKitContentBundle) {
                content.add(scene)
            }
            let skyBox = createSkyBox()!
            let anchor = AnchorEntity(.head)
            skyBox.setParent(anchor)
            content.add(anchor)
            
            skyBox.transform.translation.z = -6.0
            skyBox.transform.translation.y = 0.2
        }
        update: { updateContent in
            let imageLeft = imageData.left!
            let imageRight = imageData.right!
            
            let anchor: Entity = updateContent.entities[1]
            let skyBoxEntity = anchor.children[0]
            let sphereEntity = updateContent.entities[0].findEntity(named: "Sphere")
            var stereo_material = sphereEntity?.components[ModelComponent.self]?.materials[0] as! ShaderGraphMaterial
//            var skyBoxMaterial = UnlitMaterial()

            do{
                let textureLeft =  try TextureResource.generate(from: imageLeft.cgImage!, options: TextureResource.CreateOptions.init(semantic: nil))
                let textureRight =  try TextureResource.generate(from: imageRight.cgImage!, options: TextureResource.CreateOptions.init(semantic: nil))
//                skyBoxMaterial.color = .init(texture: .init(textureRight))
                print("texture success")
                try stereo_material.setParameter(name: "left", value: .textureResource(textureLeft))
                try stereo_material.setParameter(name: "right", value: .textureResource(textureRight))
            } catch {
                print("error loading texture \(error)")
            }
            print("trying to add material")
            skyBoxEntity.components[ModelComponent.self]?.materials = [stereo_material]
            print("added material successfully")
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
    let largePlane = MeshResource.generatePlane(width: 12.8, height: 9.6)
    var skyBoxMaterial = UnlitMaterial()
    do{
        let texture =  try TextureResource.load(named:"LoadingImageLeft")
        skyBoxMaterial.color = .init(texture: .init(texture))
    } catch {
        print("error loading texture")
    }
    skyBoxEntity.components.set(
        ModelComponent(mesh: largePlane, materials: [skyBoxMaterial])
    )
//    skyBoxEntity.setPosition(SIMD3<Float>(x:0, y:0, z:-4), relativeTo: nil)
    return skyBoxEntity
}

//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}
