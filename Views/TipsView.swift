import SwiftUI

struct LearnView: View {
    @State private var showTip1 = false
    @State private var showTip2 = false
    @State private var showTip3 = false
    @State private var showTip4 = false
    @State private var showingBottomSheet = false
    @State private var showGraphicDesignDescription = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 7) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Courses")
                            .font(.system(size: 35))
                            .fontWeight(.bold)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            //.foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                        
                        Text("Try out one of these courses to learn new skills and take on some new projects!")
                            .font(.system(size: 12))
                            .padding(.top, -20)
                            //.padding(.bottom, 20)
                            //.foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                        
                        
                        HStack {
                            Text("Design & Coding")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            
                            Text("Show All >")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 100)
                        }
                        .padding(.top, -40)
                            
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Image("graphic_design_final")
                                    .resizable()
                                    .frame(width: 150, height: 250)
                                    .onTapGesture {
                                        showGraphicDesignDescription = true
                                    }
                                    .sheet(isPresented: $showGraphicDesignDescription) {
                                        ZStack {
                                            Image("course")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .edgesIgnoringSafeArea(.all)
                                            VStack {
                                                Text(" ")
                                                Text(" ")
                                                Text(" ")
                                                Text(" ")
                                                Text(" ")
                                                Text(" ")
                                                Text("Graphic Design & Digital Art")
                                                    .font(.system(size: 25))
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(.top, 250)
                                                Text(" ")
                                                Text("Course Description Course Description\nCourse Description Course Description\nCourse Description Course Description\nCourse Description Course Description")
                                                    .font(.system(size: 22))
                                                    .multilineTextAlignment(.center) // Align the text to the center
                                                    .lineLimit(nil)
                                                    .padding(.top, 10)
                                                    .padding(.horizontal, 100)
                                                    .foregroundColor(.white)
                                            }
                                            
                                        }
                                        //.padding()
                                    }

                                Image("game_dev_final")
                                    .resizable()
                                    .frame(width: 150, height: 250)
                                Image("web_development_final")
                                    .resizable()
                                    .frame(width: 150, height: 250)
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.top, -60)
                         
                        
                        HStack {
                            Text("Design & Coding")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            
                            Text("Show All >")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 100)
                        }
                        .padding(.top, -40)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Image("ceramics")
                                    .resizable()
                                    .frame(width:150, height: 250)
                                Image("woodworking")
                                    .resizable()
                                    .frame(width: 150, height: 250)
                                Image("automotive")
                                    .resizable()
                                    .frame(width: 150, height: 250)
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.top, -60)
                    }
                    
                    Text("Tips")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        //.foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                    
                    
                    TipSectionView(question: "I don't know where to start", tip: "Starting a new project can be overwhelming. One way to make it easier is to begin with a simple project that uses materials you're familiar with. This helps you build confidence and get comfortable with the process of creating something new. Once you've completed a few simple projects, you can start to challenge yourself with more complex ones.")
                        .onTapGesture {
                            showTip1.toggle()
                        }
                    
                    if showTip1 {
                        Text("Starting a new project can be overwhelming. One way to make it easier is to begin with a simple project that uses materials you're familiar with. This helps you build confidence and get comfortable with the process of creating something new. Once you've completed a few simple projects, you can start to challenge yourself with more complex ones.")
                            .foregroundColor(.white)
                            .padding()
                            .cornerRadius(10)
                            .transition(.move(edge: .bottom))
                    }
                    
                    TipSectionView(question: "My materials list does not match up 100% with any projects", tip: "Firstly, even if your materials list does not 100% match up with any projects, this may just mean that some of the materials required for a project are not in the Make It! materials database. Click on some projects you match up with 75% or even 50% and you may realize you actually do own all the materials. Secondly, check out the Smart Materials recommendation feature. Click on the lightbulb next to a material to see our recommendations for where you might be able to find this material or materials from your list you could substitute into the project. Thirdly, ask yourself if some projects can be done without the missing materials. Is there one part of the project you could build? Any hands on experience will help develop new skills and may inspire your own creative hack for the project. Lastly, if there is a project you are really wanting to do and you are only missing a couple parts, ask a teacher or a parent if they have that part. If they don't, it may be worth asking whether this part could be purchased. Good luck!")
                        .onTapGesture {
                            showTip2.toggle()
                        }
                    
                    if showTip2 {
                        Text("Firstly, even if your materials list does not 100% match up with any projects, this may just mean that some of the materials required for a project are not in Make It!'s materials databasee. Click on some projects you match up with 75% or even 50% and you may realize you actually do own all the materials. Secondly, check out the Smart Materials recommendation feature. Click on the lightbulb next to a material to see our recommendations for where you might be able to find this material or materials from your list you could substitute into the project. Thirdly, ask yourself if some projects can be done witout the missing materials. If there one part of the project you could build? Any hands on experience will be help develop new skills and may inspire your own creative hack for the project. Lastly, if there is a project you are really wanting to do and you are only missing a couple parts, ask a teacher or a parent if they have that part. If they don't, it may be worth asking whether this part could be purchased. Good luck!")
                            .foregroundColor(.white)
                            .padding()
                            .cornerRadius(10)
                            .transition(.move(edge: .bottom))
                    }
                    
                    TipSectionView(question: "I'm stuck on a project", tip: "Whether you're new to a particular medium or you're struggling with a specific aspect of your project, there are many resources available online that can help. A great place to start is YouTube, where you can find a wide range of tutorials on everything from drawing and painting to woodworking and jewelry-making. You can also try searching for forums or online communities dedicated to your particular hobby or interest. These can be a great way to connect with other like-minded individuals and get advice and feedback on your work. Finally, don't forget about social media! Platforms like Instagram and TikTok are filled with talented creators who are happy to share their tips and tricks.")
                        .onTapGesture {
                            showTip3.toggle()
                        }
                    
                    if showTip3 {
                        Text("Whether you're new to a particular medium or you're struggling with a specific aspect of your project, there are many resources available online that can help. A great place to start is YouTube, where you can find a wide range of tutorials on everything from drawing and painting to woodworking and jewelry-making. You can also try searching for forums or online communities dedicated to your particular hobby or interest. These can be a great way to connect with other like-minded individuals and get advice and feedback on your work. Finally, don't forget about social media! Platforms like Instagram and TikTok are filled with talented creators who are happy to share their tips and tricks.")
                            .foregroundColor(.white)
                            .padding()
                            .cornerRadius(10)
                            .transition(.move(edge: .bottom))
                    }
                    
                    
                    /*
                    Text("Resources")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        //.foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Youtube")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                            .padding(.leading, 8)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: { UIApplication.shared.open(URL(string: "https://www.youtube.com/@DIYPerks")!) }) {
                                Text("• ")
                                + Text("DIY Perks").underline()
                            }
                            .padding(.leading, 16)
                            Button(action: { UIApplication.shared.open(URL(string: "https://www.youtube.com/@Iliketomakestuff")!) }) {
                                Text("• ")
                                + Text("I Like To Make Stuff").underline()
                            }
                            .padding(.leading, 16)
                            Button(action: { UIApplication.shared.open(URL(string: "https://www.youtube.com/@TheKingofRandom")!) }) {
                                Text("• ")
                                + Text("The King of Random").underline()
                            }
                            .padding(.leading, 16)
                        }
                        
                        Text("Books")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                            .padding(.leading, 8)
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: { UIApplication.shared.open(URL(string: "https://www.amazon.com/Maker-Movement-Manifesto-Innovation-Tinkerers/dp/0071821120/ref=sr_1_1?crid=2GE21YW6J5YGI&keywords=The+Maker+Movement+Manifesto&qid=1681132907&s=books&sprefix=the+maker+movement+manifesto%2Cstripbooks%2C86&sr=1-1")!) }) {
                                Text("• ")
                                + Text("The Maker Movement Manifesto").underline()
                            }
                            .padding(.leading, 16)
                            Button(action: { UIApplication.shared.open(URL(string: "https://www.amazon.com/gp/product/1616286091/ref=sw_img_1?smid=ATVPDKIKX0DER&psc=1")!) }) {
                                Text("• ")
                                + Text("The Art of Tinkering").underline()
                            }
                            .padding(.leading, 16)
                            Button(action: { UIApplication.shared.open(URL(string: "https://www.amazon.com/Getting-Started-Arduino-Electronics-Prototyping/dp/1680456938/ref=sr_1_3?crid=2RJRA87ZYNEJ3&keywords=getting+started+with+arduino&qid=1681132923&s=books&sprefix=gettign+started+with+arduino%2Cstripbooks%2C84&sr=1-3")!) }) {
                                Text("• ")
                                + Text("Getting Started With Arduino").underline()
                            }
                            .padding(.leading, 16)
                        }
                        
                        Text("Websites")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                            .padding(.leading, 8)
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: { UIApplication.shared.open(URL(string: "https://makerspaces.make.co/")!) }) {
                                Text("• ")
                                + Text("Find a Makespace Near You!").underline()
                            }
                            .padding(.leading, 16)
                            Button(action: { UIApplication.shared.open(URL(string: "https://www.sparkfun.com/")!) }) {
                                Text("• ")
                                + Text("SparkFun").underline()
                            }
                            .padding(.leading, 16)
                            Button(action: { UIApplication.shared.open(URL(string: "https://hackaday.com/")!) }) {
                                Text("• ")
                                + Text("Hackaday").underline()
                            }
                            .padding(.leading, 16)
                        }
                        
                    }
                     */
                    
                    //Spacer()
                    
                }
                .padding()
            }
        }
        .navigationBarTitle("Materials List")
    }
}

struct TipSectionView: View {
    var question: String
    var tip: String
    
    @State private var showTip = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .cornerRadius(10)
                .frame(width: 370, height: 50)
                .foregroundColor(Color(red: 104/255, green: 188/255, blue: 195/255, opacity: 0.7))
                .onTapGesture {
                    showTip.toggle()
                }
            
            HStack() {
                Text(question)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Image(systemName: showTip ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
            }
            .padding()
        }
        
        if showTip {
            Text(tip)
                .foregroundColor(.black)
                .padding()
                .transition(.move(edge: .bottom))
        }
    }
}


struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}

