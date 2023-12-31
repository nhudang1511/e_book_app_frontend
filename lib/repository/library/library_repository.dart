import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_book_app/model/library_model.dart';
import 'package:e_book_app/repository/library/base_library_repository.dart';

class LibraryRepository extends BaseLibraryRepository{

  final FirebaseFirestore _firebaseFirestore;

  LibraryRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addBookInLibrary(Library library) {
    return _firebaseFirestore.collection('libraries').add(library.toDocument());
  }

  @override
  Stream<List<Library>> getAllLibraries() {
    return _firebaseFirestore
        .collection('libraries')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Library.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> removeBookInLibrary(Library library) {
    return _firebaseFirestore
        .collection('libraries')
        .where('bookId', isEqualTo: library.bookId)
        .where('userId', isEqualTo: library.userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
  }

}