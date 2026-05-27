import Foundation
import Supabase

enum AppSupabase {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://qgxgvrawkorukqxaoneb.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFneGd2cmF3a29ydWtxeGFvbmViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4OTMzNjgsImV4cCI6MjA5NTQ2OTM2OH0.0wCfxCKE9BrTgiL4QwBTaQWfHGcgJlQV3d4s5dor9E0"
    )
}
