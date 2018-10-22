describe ImageHost::Image do
  ImageHost.image_dir = File.join(File.dirname(Dir.current), "test-data")
  test_img = ImageHost::Image.new "1px-transparent.png"
  it "has the right filepath" do
    test_img.filepath = File.join image_dir, "test-data", "1px-transparent.png"
  end
  it "has the right mime type" do
    test_img.mime_type.should eq "image/png"
  end
end
