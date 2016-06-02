module RecentHelper

  def floor_as_time(time, seconds=60)
    Time.at((time.to_f / seconds).round * seconds).utc
  end
 
  def floor(time, seconds=60)
    floor_as_time(time, seconds).iso8601
  end

  def ceil(time, seconds=60)
    (floor_as_time(time, seconds) + seconds - 1.second).utc.iso8601
  end

  def recent_title
    if params[:year] && params[:month]
      date = DateTime.parse("#{params[:year]}/#{params[:month]}")
      "Documents from #{date.strftime("%B")} #{date.year}"
    elsif params[:year]
      "Documents from #{params[:year]}"
    else
      "Recently Uploaded (last two weeks)"
    end
  end

  def bucket_as_date(bucket)
    DateTime.parse(bucket).strftime("%Y: %B")
  end
  
  def bucket_as_month(bucket)
    DateTime.parse(bucket).strftime("%B")
  end

  def bucket_as_params(bucket)
    date = DateTime.parse(bucket)
    {:year => date.year, :month => date.month}
  end
end
