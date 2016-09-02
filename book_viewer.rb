require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map do |t|
      "<p>#{t}</p>"
    end.join
  end
end

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  
  chapter = @contents[number - 1]
  @title = "chapter #{number} #{chapter}"
  @chapter = File.read("data/chp#{number}.txt") 
  
  erb :chapter
end

def search_for(query)
  results = []
  return results unless query
  @contents.each_with_index do |chapter, idx|
    number = idx + 1
    chapters = File.read("data/chp#{number}.txt")
    results << {number: number, chapter: @contents[idx]} if chapters.include?(query)
  end
  results
end

get "/search" do
  @results = search_for(params[:query])
  erb :search
end

not_found do
  redirect "/"
end