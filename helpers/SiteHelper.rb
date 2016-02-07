module SiteHelper
  def user_email(user)
    user.email if user && user.email.present?
  end

  def all_audio_files(audio_files)
    audio_files.map do |file|
      "<option>#{file.id} #{file.original_title}</option>"
    end.join("\n")
  end

  def audio_files_make_playlsit(audio_files)
    audio_files.map do |file|
      "<option value = #{file.id}> #{file.id} #{file.original_title} </option>"
    end.join("\n")
  end

  def audio_files_playlist(playlists)
    playlists.map do |playlist|
      "<option value = #{playlist.id}> #{playlist.name}</option>"
    end.join("\n")
  end
end
