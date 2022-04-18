//
//  ContentView.swift
//  Devote
//
//  Created by Metin Atalay on 17.04.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - PROP
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State var task: String = ""
    @State var showNewTaskItem: Bool = false
    
    // MARK: - FETCHING DATA
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // MARK: - FUNC
    
    
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // MARK: - MAINVIEW
                VStack {
                    // MARK: - HEADER
                    
                    HStack(spacing: 10) {
                        
                        //TITLE
                        
                        Text("Devote")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.heavy)
                            .padding(.leading, 4)
                        
                        Spacer()
                        
                        //EDIT BOTTON
                        
                        EditButton()
                            .font(.system(size: 16 ,weight: .semibold, design: .rounded))
                            .padding(.horizontal, 10)
                            .frame(minWidth: 70, minHeight: 24)
                            .background(Capsule().stroke(.white, lineWidth: 2))
                        
                        //APPEERANCE BUTTON
                        
                        Button {
                            isDarkMode.toggle()
                            playSound(sound: "sound-up", type: "mp3")
                        } label: {
                            Image(systemName: isDarkMode ? "moon.circle.fill": "moon.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .font(.system(.title, design: .rounded))
                        }

                        
                    }
                    .padding()
                    .foregroundColor(.white)
                    
                    Spacer(minLength: 80)
                    
                    // MARK: - NEW TASK BUTTON
                    
                    Button {
                        showNewTaskItem = true
                        playSound(sound: "sound-ding", type: "mp3")
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                        
                        Text("New Task")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(backgroundGradient.clipShape(Capsule()))
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 8, x: 0, y: 4)
                    
                    // MARK: - TASKS
                    
                    
                    List {
                        ForEach(items) { item in
                            ListRowItemView(item: item)
                        } //: FOR
                        .onDelete(perform: deleteItems)
                    } //: LIST
                    .listStyle(InsetGroupedListStyle())
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.3 ), radius: 12)
                } //: VSTACK
                .blur(radius: showNewTaskItem ? 8.0:0 , opaque: false)
                .transition(.move(edge: .bottom))
                .animation(.easeOut(duration: 0.5))
                
                // MARK: - New Task ITEM
                
                if  showNewTaskItem {
                    
                    BlankView(
                        backgroundColor: isDarkMode ? .black: .gray,
                        backgroundOpacity: isDarkMode ?  0.3 : 0.5)
                        .onTapGesture {
                            withAnimation(){
                                showNewTaskItem = false
                            }
                        }
                    
                    NewTaskItemView(isShowing: $showNewTaskItem)
                }
                
            } //: ZStack
            .onAppear(perform: {
                UITableView.appearance().backgroundColor = UIColor.clear
            })
            .navigationTitle("Daily Tasks")
            .navigationBarHidden(true)
            .background(BackgroundImageView().blur(radius: showNewTaskItem ? 8.0:0 , opaque: false) )
            .background(backgroundGradient.ignoresSafeArea(.all))
            
        } //: NavigationView
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
