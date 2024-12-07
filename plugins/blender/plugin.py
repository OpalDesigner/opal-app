bl_info = {
    "name": "Export to S3",
    "blender": (2, 80, 0),
    "category": "Import-Export",
}

import bpy
import boto3
from bpy_extras.io_utils import ExportHelper
from bpy.props import StringProperty
from bpy.types import Operator
import os

class ExportToS3(Operator, ExportHelper):
    bl_idname = "export.to_s3"
    bl_label = "Export to S3 (USDZ)"
    filename_ext = ".usdz"

    bucket_name: StringProperty(
        name="S3 Bucket Name",
        description="Name of the S3 bucket to upload to",
        default="opal-designer"
    )

    object_name: StringProperty(
        name="S3 Object Name",
        description="Name of the object in S3 (including any prefix)",
        default="uploads/untitled.usdz"
    )

    def execute(self, context):
        self.report({'INFO'}, f"Executing Export to S3 Plugin")
        filepath = self.filepath
        bucket = self.bucket_name
        
        # Extract filename from filepath and combine with any prefix from object_name
        filename = os.path.basename(filepath)
        prefix = os.path.dirname(self.object_name).rstrip('/')
        object_name = f"{prefix}/{filename}" if prefix else filename

        # Export the current scene to USDZ
        try:
            bpy.ops.wm.usd_export(
                filepath=filepath,
                export_animation=True,
                export_materials=True,
                export_textures=True,
            )
            self.report({'INFO'}, f"Exported USDZ file to {filepath}")
        except Exception as e:
            self.report({'ERROR'}, f"Error exporting USDZ: {str(e)}")
            return {'CANCELLED'}

        # Upload to S3
        s3_client = boto3.client('s3', region_name='us-east-1')
        try:
            self.report({'INFO'}, f"Uploading '{filepath}' to {bucket}/{object_name}")
            s3_client.upload_file(filepath, bucket, object_name)
            self.report({'INFO'}, f"File exported and uploaded to S3: {bucket}/{object_name}")
        except Exception as e:
            self.report({'ERROR'}, f"Error uploading to S3: {str(e)}")
            return {'CANCELLED'}

        return {'FINISHED'}

def menu_func_export(self, context):
    self.layout.operator(ExportToS3.bl_idname, text="Export to S3")

def register():
    bpy.utils.register_class(ExportToS3)
    bpy.types.TOPBAR_MT_file_export.append(menu_func_export)

def unregister():
    bpy.utils.unregister_class(ExportToS3)
    bpy.types.TOPBAR_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
    register()
