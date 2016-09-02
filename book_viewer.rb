require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "pry"

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, idx|
      "<p id=paragraph#{idx}>#{line}</p>"
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

def each_chapter(&block)
    @contents.each_with_index do |name, idx|
    number = idx + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def search_for(query)
  results = []
  return results unless query
  
  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, idx|
      matches[idx] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraph: matches} if matches.any?
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